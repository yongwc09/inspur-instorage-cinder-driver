双活卷的管理
============
驱动提供了对双活卷的管理能力。

支持的操作
----------
目前支持对双活卷的以下操作。
1. 创建
2. 删除
3. 挂载
4. 卸载

配置说明
--------
为了支持双活卷的管理，驱动增加了以下配置参数

```
instorage_mcs_enable_aa
[True/False] 是否启用双活管理

instorage_mcs_aa_volpool_name_map
Pool0:Pool1  创建双活卷时主节点池与备用节点池对应关系，Pool0参数为instorage_mcs_volpool_name中定义。

instorage_mcs_aa_iogrp_map
iogrp_id1:iogrp_id2 创建双活卷时主节点io组与备节点io组对应关系，为io组ID号，iogrp_id1参数为instorage_mcs_vol_iogrp中定义
```
需要保持池对应关系和IO组对应关系的顺序一致，instorage_mcs_volpool_name及instorage_mcs_vol_iogrp参数定义的值为主站点中的信息。

主机创建站点参数
----------------
为了使双活卷映射到主机，主机创建时需要指定站点名称。当前站点名称的选择逻辑为
1. 根据卷名称，确定master卷所在的IO组。
2. 根据IO组确定IO组所属的站点，该站点即为选择的站点。

其他说明
--------
1. 当OpenStack管理的双活集群需要同时可以创建普通卷以及双活卷时，需要启动两个存储后端。其中一个用作普通卷管理，另外一个用作双活卷管理。
2. 建议在两个站点上分别创建两个同样容量的池，单独用作双活卷管理使用。
3. 建议创建单独的池供普通卷创建使用。

配置参考
-------
```
# 双活卷管理后端
[G2-1]
volume_backend_name = G2-AA
volume_driver=cinder.volume.drivers.inspur.instorage.instorage_iscsi.InStorageMCSISCSIDriver
san_ip = 100.7.46.160
san_login = superuser
san_password = passw0rd
instorage_mcs_volpool_name = Pool2
instorage_mcs_vol_iogrp=0
instorage_mcs_enable_aa=True
instorage_mcs_aa_volpool_name_map=Pool2:Pool3
instorage_mcs_aa_iogrp_map=0:1

# 普通卷管理后端
[G2-2]
volume_backend_name = G2
volume_driver=cinder.volume.drivers.inspur.instorage.instorage_iscsi.InStorageMCSISCSIDriver
san_ip = 100.7.46.160
san_login = superuser
san_password = passw0rd
instorage_mcs_volpool_name = Pool0
```
