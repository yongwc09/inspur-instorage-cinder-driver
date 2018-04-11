# Copyright 2017 Inspur Corp.
# All Rights Reserved.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
#
"""
Volume FC driver for Inspur InStorage family and MCS storage systems.

Notes:
1. Make sure you config the password or key file. If you specify both
a password and a key file, this driver will use the key file only.
2. When a key file is used for authentication, the private key is stored
in a secure manner by the user or system administrator.
3. The default setting of creating volumes are "-rsize 2% -autoexpand
-grainsize 256 -warning 0".  These can be changed in the Cinder configuration
file or by using volume types(recommended only for advanced users).

Limitations:
1. The driver expects CLI output in English, but the error messages may be in a
localized format.
2. when you clone or create volumes from snapshots, it not support that the
source and target_rep are different size.

Perform necessary work to make a FC connection:
To be able to create an FC connection from a given host to a volume,
we must:
1. Translate the given WWNN to a host name
2. Create new host on the storage system if it does not yet exist
3. Map the volume to the host if it is not already done
4. Return the connection information for relevant nodes
   (in the proper I/O group)
"""

DRIVER_RUN_VERSION = '@RUN_VERSION@'

# TODO !!!ATTENTION
# the openstack common package is move out from project
# as some independent library from Kilo
if DRIVER_RUN_VERSION <= 'JUNO':
    from cinder.openstack.common import log as logging
    from cinder.openstack.common import excutils
else:
    from oslo_log import log as logging
    from oslo_utils import excutils

# TODO !!!ATTENTION
# from Ocata, lock from coordination is used instead of utils
if DRIVER_RUN_VERSION <= 'NEWTON':
    from cinder import utils as coordination
    def synchronized_lock(lockname):
        return coordination.synchronized(lockname, external=True)
else:
    from cinder import coordination
    def synchronized_lock(lockname):
        return coordination.synchronized(lockname)

from cinder import exception
from cinder.i18n import _
from cinder.volume import driver
from cinder.volume.drivers.inspur.instorage import instorage_common

# TODO !!!ATTENTION
# from Ocata the name of AddFCZone changed to be add_fc_zone
# from Ocata the name of RemoveFCZone changed to be remove_fc_zone
# do a candition import
if DRIVER_RUN_VERSION <= 'NEWTON':
    from cinder.zonemanager.utils import AddFCZone as fczm_utils_add_fc_zone
    from cinder.zonemanager.utils import RemoveFCZone as fczm_utils_remove_fc_zone
else:
    from cinder.zonemanager.utils import add_fc_zone as fczm_utils_add_fc_zone
    from cinder.zonemanager.utils import remove_fc_zone as fczm_utils_remove_fc_zone

LOG = logging.getLogger(__name__)


class InStorageMCSFCDriver(instorage_common.InStorageMCSCommonDriver,
                           driver.FibreChannelDriver):
    """INSPUR InStorage MCS FC volume driver.

    Version history:

    .. code-block:: none

        1.0 - Initial driver
    """

    VERSION = "1.0.0"

    # ThirdPartySystems wiki page
    CI_WIKI_NAME = "INSPUR_CI"

    def __init__(self, *args, **kwargs):
        super(InStorageMCSFCDriver, self).__init__(*args, **kwargs)
        self.protocol = 'FC'

    @fczm_utils_add_fc_zone # from Ocata, the add_fc_zone is used instead of AddFCZone
    def initialize_connection(self, volume, connector):
        """Perform necessary work to make a FC connection."""
        @synchronized_lock('instorage-host' + self._state['system_id']
                           + connector['host'])
        def _do_initialize_connection_locked():
            return self._do_initialize_connection(volume, connector)
        return _do_initialize_connection_locked()

    def _do_initialize_connection(self, volume, connector):
        """Perform necessary work to make a FC connection.

        To be able to create an FC connection from a given host to a
        volume, we must:
        1. Translate the given WWNN to a host name
        2. Create new host on the storage system if it does not yet exist
        3. Map the volume to the host if it is not already done
        4. Return the connection information for relevant nodes (in the
           proper I/O group)

        """
        LOG.debug('enter: initialize_connection: volume %(vol)s with connector'
                  ' %(conn)s', {'vol': volume['id'], 'conn': connector})

        # get host according to FC protocol
        connector = connector.copy()
        connector.pop('initiator', None)

        volume_name = self._get_target_vol(volume)

        # Check if a host object is defined for this host name
        host_name = self._assistant.get_host_from_connector(connector)
        if host_name is None:
            # Host does not exist - add a new host to InStorage/MCS
            site = self._assistant.get_volume_prefer_site_name(volume_name)
            host_name = self._assistant.create_host(connector, site)

        volume_attributes = self._assistant.get_vdisk_attributes(volume_name)
        if volume_attributes is None:
            msg = (_('initialize_connection: Failed to get attributes'
                     ' for volume %s.') % volume_name)
            LOG.error(msg)
            raise exception.VolumeDriverException(message=msg)

        lun_id = self._assistant.map_vol_to_host(volume_name, host_name, True)
        try:
            preferred_node = volume_attributes['preferred_node_id']
            IO_group = volume_attributes['IO_group_id']
        except KeyError as e:
            LOG.error(_('Did not find expected column name in '
                        'lsvdisk: %s.'), e)
            raise exception.VolumeBackendAPIException(
                data=_('initialize_connection: Missing volume attribute for '
                       'volume %s.') % volume_name)

        try:
            # Get preferred node and other nodes in I/O group
            preferred_node_entry = None
            io_group_nodes = []
            for node in self._state['storage_nodes'].values():
                if node['id'] == preferred_node:
                    preferred_node_entry = node
                if node['IO_group'] == IO_group:
                    io_group_nodes.append(node)

            if not len(io_group_nodes):
                msg = (_('initialize_connection: No node found in '
                         'I/O group %(gid)s for volume %(vol)s.') %
                       {'gid': IO_group, 'vol': volume_name})
                LOG.error(msg)
                raise exception.VolumeBackendAPIException(data=msg)

            if not preferred_node_entry:
                # Get 1st node in I/O group
                preferred_node_entry = io_group_nodes[0]
                LOG.warning(_('initialize_connection: Did not find a '
                              'preferred node for volume %s.'), volume_name)

            io_groups = self._assistant.get_volume_iogrps(volume_name)

            properties = {}
            properties['target_discovered'] = False
            properties['target_lun'] = lun_id
            properties['volume_id'] = volume['id']

            visible_wwpns = self._assistant.get_conn_fc_wwpns(host_name)

            available_wwpns = [] 
            for node in self._state['storage_nodes'].values():
                if node['IO_group'] not in io_groups:
                    continue
                available_wwpns.extend(node['WWPN'])
            conn_wwpns = list(set(visible_wwpns) & set(available_wwpns))

            properties['target_wwn'] = conn_wwpns

            i_t_map = self._make_initiator_target_map(connector['wwpns'],
                                                      conn_wwpns)
            properties['initiator_target_map'] = i_t_map

        except Exception:
            with excutils.save_and_reraise_exception():
                self._do_terminate_connection(volume, connector)
                LOG.error(_('initialize_connection: Failed '
                            'to collect return '
                            'properties for volume %(vol)s and connector '
                            '%(conn)s.\n'), {'vol': volume,
                                             'conn': connector})

        LOG.debug('leave: initialize_connection:\n volume: %(vol)s\n '
                  'connector %(conn)s\n properties: %(prop)s',
                  {'vol': volume['id'], 'conn': connector,
                   'prop': properties})

        return {'driver_volume_type': 'fibre_channel', 'data': properties, }

    def _make_initiator_target_map(self, initiator_wwpns, target_wwpns):
        """Build a simplistic all-to-all mapping."""
        i_t_map = {}
        for i_wwpn in initiator_wwpns:
            i_t_map[str(i_wwpn)] = []
            for t_wwpn in target_wwpns:
                i_t_map[i_wwpn].append(t_wwpn)

        return i_t_map

    @fczm_utils_remove_fc_zone # from Ocata, the remove_fc_zone is used instead of RemoveFCZone
    def terminate_connection(self, volume, connector, **kwargs):
        """Cleanup after an FC connection has been terminated."""
        # If a fake connector is generated by nova when the host
        # is down, then the connector will not have a host property,
        # In this case construct the lock without the host property
        # so that all the fake connectors to an MCS are serialized
        host = connector['host'] if 'host' in connector else ""

        @synchronized_lock('instorage-host' + self._state['system_id'] + host)
        def _do_terminate_connection_locked():
            return self._do_terminate_connection(volume, connector,
                                                 **kwargs)
        return _do_terminate_connection_locked()

    def _do_terminate_connection(self, volume, connector, **kwargs):
        """Cleanup after an FC connection has been terminated.

        When we clean up a terminated connection between a given connector
        and volume, we:
        1. Translate the given connector to a host name
        2. Remove the volume-to-host mapping if it exists
        3. Delete the host if it has no more mappings (hosts are created
           automatically by this driver when mappings are created)
        """
        LOG.debug('enter: terminate_connection: volume %(vol)s with connector'
                  ' %(conn)s', {'vol': volume['id'], 'conn': connector})
        vol_name = self._get_target_vol(volume)
        info = {}
        if 'host' in connector:
            # get host according to FC protocol
            connector = connector.copy()

            connector.pop('initiator', None)
            info = {'driver_volume_type': 'fibre_channel',
                    'data': {}}

            host_name = self._assistant.get_host_from_connector(
                connector, volume_name=vol_name)
            if host_name is None:
                msg = (_('terminate_connection: Failed to get host name from'
                         ' connector.'))
                LOG.error(msg)
                raise exception.VolumeDriverException(message=msg)
        else:
            host_name = None

        # Unmap volumes, if hostname is None, need to get value from vdiskmap
        host_name = self._assistant.unmap_vol_from_host(vol_name, host_name)

        # Host_name could be none
        if host_name:
            resp = self._assistant.check_host_mapped_vols(host_name)
            if not len(resp):
                LOG.info(_("Need to remove FC Zone, building initiator "
                           "target map."))
                # Build info data structure for zone removing
                if 'wwpns' in connector and host_name:
                    target_wwpns = []
                    # Returning all target_wwpns in storage_nodes, since
                    # we cannot determine which wwpns are logged in during
                    # a VM deletion.
                    for node in self._state['storage_nodes'].values():
                        target_wwpns.extend(node['WWPN'])
                    init_targ_map = (self._make_initiator_target_map
                                     (connector['wwpns'],
                                      target_wwpns))
                    info['data'] = {'initiator_target_map': init_targ_map}
                # No volume mapped to the host, delete host from array
                self._assistant.delete_host(host_name)

        LOG.debug('leave: terminate_connection: volume %(vol)s with '
                  'connector %(conn)s', {'vol': volume['id'],
                                         'conn': connector})
        return info
