#!/bin/sh
#
# Inspur Copyright (C) 2017 - 2018.
# This script is used to modify /etc/multipath.conf, to set optimazed config for G2 serials.
#
# history
# 2018.01.23  v1.1  no comment blacklist.
#                   fix centos 5.x no schema bug.
# 2017.12.10  v1.0  initial release.

#
#520E:
#    device {
#           vendor "Inspur"
#           product "AS Manager CM24"
#           #path_grouping_policy multibus
#           path_grouping_policy group_by_prio
#           path_selector "round-robin 0"
#           prio alua
#           feature "1 queue_if_no_path"
#           failback immediate
#           rr_weight uniform
#           rr_min_io 1000
#           rr_min_io_rq 1
#         getuid_callout "/lib/udev/scsi_id --whitelisted --device=/dev/%n"
#        }
#
#AS5500:
#   device {
#           vendor "Inspur"
#           product "AS Manager 5500"
#           #path_grouping_policy multibus
#           path_grouping_policy group_by_prio
#           path_selector "round-robin 0"
#           prio alua
#           feature "1 queue_if_no_path"
#           failback immediate
#           rr_weight uniform
#           rr_min_io 1000
#           rr_min_io_rq 1
#         getuid_callout "/lib/udev/scsi_id --whitelisted --device=/dev/%n"
#        }





#step 0, multipath.conf slices

cfgkux2="
    device {
      vendor                  \"INSPUR\"
      product                 \"MCS\"
      getuid_callout          \"/sbin/scsi_id -g -u -s /block/%n\"
      prio_callout            \"/sbin/mpath_prio_alua /dev/%n\"
      features                \"1 queue_if_no_path\"
      hardware_handler        \"0\"
      path_grouping_policy    group_by_prio
      failback                immediate
      rr_weight               uniform
      rr_min_io               1000
      path_checker            tur
    }
"

cfgkux3="
    device {
      vendor                  \"INSPUR\"
      product                 \"MCS\"
      path_grouping_policy    group_by_prio
      path_selector           \"round-robin 0\"
      path_checker            tur
      features                \"1 queue_if_no_path\"
      hardware_handler        \"0\"
      prio                    alua
      failback                immediate
      rr_weight               uniform
      rr_min_io               1000
    }
"

cfglinx40="
    device {
      vendor                  \"INSPUR\"
      product                 \"MCS\"
      path_grouping_policy    group_by_prio
      getuid_callout          \"/sbin/scsi_id --whitelisted --page=0x83 --devpath=/block/%n\"
      path_selector           \"round-robin 0\"
      path_checker            tur
      features                \"1 queue_if_no_path\"
      hardware_handler        \"0\"
      prio                    alua
      failback                immediate
      rr_weight               uniform
      rr_min_io               1000
      rr_min_io_rq            1
    }
"

cfglinx60="
    device {
      vendor                  \"INSPUR\"
      product                 \"MCS\"
      path_grouping_policy    group_by_prio
      getuid_callout          \"/lib/udev/scsi_id --whitelisted --device=/dev/%n\"
      path_selector           \"round-robin 0\"
      path_checker            tur
      features                \"1 queue_if_no_path\"
      hardware_handler        \"0\"
      prio                    alua
      failback                immediate
      rr_weight               uniform
      rr_min_io               1000
      rr_min_io_rq            1
    }
"

cfglinx80="
    device {
      vendor                  \"INSPUR\"
      product                 \"MCS\"
      path_grouping_policy    group_by_prio
      path_selector           \"round-robin 0\"
      path_checker            tur
      features                \"1 queue_if_no_path\"
      hardware_handler        \"0\"
      prio                    alua
      failback                immediate
      rr_weight               uniform
      rr_min_io               1000
      rr_min_io_rq            1
    }
"

cfgrhel50="
    device {
      vendor                  \"INSPUR\"
      product                 \"MCS\"
      path_grouping_policy    group_by_prio
      path_selector           \"round-robin 0\"
      path_checker            tur
      features                \"1 queue_if_no_path\"
      hardware_handler        \"0\"
      prio                    alua
      failback                immediate
      rr_weight               uniform
      rr_min_io               1000
    }
"

cfgrhel56="
    device {
      vendor                  \"INSPUR\"
      product                 \"MCS\"
      path_grouping_policy    group_by_prio
      path_selector           \"round-robin 0\"
      path_checker            tur
      features                \"1 queue_if_no_path\"
      hardware_handler        \"0\"
      failback                immediate
      rr_weight               uniform
      rr_min_io               1000
    }
"

cfgrhel60="
    device {
      vendor                  \"INSPUR\"
      product                 \"MCS\"
      path_grouping_policy    group_by_prio
      getuid_callout          \"/lib/udev/scsi_id --whitelisted --device=/dev/%n\"
      path_selector           \"round-robin 0\"
      path_checker            tur
      features                \"1 queue_if_no_path\"
      hardware_handler        \"0\"
      prio                    alua
      failback                immediate
      rr_weight               uniform
      rr_min_io               1000
    }
"

cfgrhel70="
    device {
      vendor                  \"INSPUR\"
      product                 \"MCS\"
      path_grouping_policy    group_by_prio
      path_selector           \"round-robin 0\"
      path_checker            tur
      features                \"1 queue_if_no_path\"
      hardware_handler        \"0\"
      prio                    alua
      failback                immediate
      rr_weight               uniform
      rr_min_io               1000
    }
"

cfgsles10="
    device {
      vendor                  \"INSPUR\"
      product                 \"MCS\"
      features                \"1 queue_if_no_path\"
      hardware_handler        \"0\"
      path_selector           \"round-robin 0\"
      path_grouping_policy    group_by_prio
      failback                immediate
      rr_weight               uniform
      rr_min_io               1000
      path_checker            tur
      prio                    alua
    }
"

cfgsles11="
    device {
      vendor                  \"INSPUR\"
      product                 \"MCS\"
      getuid_callout          \"/lib/udev/scsi_id --whitelisted --device=/dev/%n\"
      features                \"1 queue_if_no_path\"
      hardware_handler        \"0\"
      path_selector           \"round-robin 0\"
      path_grouping_policy    group_by_prio
      failback                immediate
      rr_weight               uniform
      rr_min_io               1000
      path_checker            tur
      prio                    alua
    }
"

cfgsles12="
    device {
      vendor                  \"INSPUR\"
      product                 \"MCS\"
      path_grouping_policy    group_by_prio
      path_selector           \"round-robin 0\"
      path_checker            tur
      features                \"1 queue_if_no_path\"
      hardware_handler        \"0\"
      prio                    alua
      failback                immediate
      rr_weight               uniform
      rr_min_io               1000
    }
"

cfgub16="
    device {
      vendor                  \"INSPUR\"
      product                 \"MCS\"
      path_grouping_policy    group_by_prio
      path_selector           \"round-robin 0\"
      path_checker            tur
      features                \"1 queue_if_no_path\"
      hardware_handler        \"0\"
      prio                    alua
      failback                immediate
      rr_weight               uniform
      rr_min_io               1000
    }
"

cfgkylin40="
    device {
      vendor                  \"INSPUR\"
      product                 \"MCS\"
      path_grouping_policy    group_by_prio
      path_selector           \"round-robin 0\"
      path_checker            tur
      features                \"1 queue_if_no_path\"
      hardware_handler        \"0\"
      prio                    alua
      failback                immediate
      rr_weight               uniform
      rr_min_io               1000
    }
"

#step 1, check Linux os
osname=`uname`
if [ ${osname} != Linux ];
then
 echo not supported os: ${osname}
 exit 1
fi


#step 2, check distribute version, 
disttype=
cfgx=

#oracle linux
if [ -f /etc/oracle-release ]; then
 disttype=oraclelinux
 if [ 1 -eq `grep -c 5[.]0 /etc/oracle-release` ]; then
  vr=50
  cfgx=${cfgrhel50}
 elif [ 1 -eq `grep -c 5[.]6 /etc/oracle-release` ]; then
  vr=56
  cfgx=${cfgrhel56}
 elif [ 1 -eq `grep -c 5[.]7 /etc/oracle-release` ]; then
  vr=57
  cfgx=${cfgrhel56}
 elif [ 1 -eq `grep -c 5[.]8 /etc/oracle-release` ]; then
  vr=58
  cfgx=${cfgrhel56}
 elif [ 1 -eq `grep -c 5[.]9 /etc/oracle-release` ]; then
  vr=59
  cfgx=${cfgrhel56}
 elif [ 1 -eq `grep -c 5[.]10 /etc/oracle-release` ]; then
  vr=510
  cfgx=${cfgrhel56}
 elif [ 1 -eq `grep -c 5[.]11 /etc/oracle-release` ]; then
  vr=511
  cfgx=${cfgrhel56}
 elif [ 1 -eq `grep -c 6[.]0 /etc/oracle-release` ]; then
  vr=60
  cfgx=${cfgrhel60}
 elif [ 1 -eq `grep -c 6[.]1 /etc/oracle-release` ]; then
  vr=61
  cfgx=${cfgrhel60}
 elif [ 1 -eq `grep -c 6[.]2 /etc/oracle-release` ]; then
  vr=62
  cfgx=${cfgrhel60}
 elif [ 1 -eq `grep -c 6[.]3 /etc/oracle-release` ]; then
  vr=63
  cfgx=${cfgrhel60}
 elif [ 1 -eq `grep -c 6[.]4 /etc/oracle-release` ]; then
  vr=64
  cfgx=${cfgrhel60}
 elif [ 1 -eq `grep -c 6[.]5 /etc/oracle-release` ]; then
  vr=65
  cfgx=${cfgrhel60}
 elif [ 1 -eq `grep -c 6[.]6 /etc/oracle-release` ]; then
  vr=66
  cfgx=${cfgrhel60}
 elif [ 1 -eq `grep -c 6[.]7 /etc/oracle-release` ]; then
  vr=67
  cfgx=${cfgrhel60}
 elif [ 1 -eq `grep -c 6[.]8 /etc/oracle-release` ]; then
  vr=68
  cfgx=${cfgrhel60}
 elif [ 1 -eq `grep -c 6[.]9 /etc/oracle-release` ]; then
  vr=69
  cfgx=${cfgrhel60}
 elif [ 1 -eq `grep -c 7[.]0 /etc/oracle-release` ]; then
  vr=70
  cfgx=${cfgrhel70}
 elif [ 1 -eq `grep -c 7[.]1 /etc/oracle-release` ]; then
  vr=71
  cfgx=${cfgrhel70}
 elif [ 1 -eq `grep -c 7[.]2 /etc/oracle-release` ]; then
  vr=72
  cfgx=${cfgrhel70}
 elif [ 1 -eq `grep -c 7[.]3 /etc/oracle-release` ]; then
  vr=73
  cfgx=${cfgrhel70}
 elif [ 1 -eq `grep -c 7[.]4 /etc/oracle-release` ]; then
  vr=74
  cfgx=${cfgrhel70}
 fi

#centos
elif [ -f /etc/centos-release ]; then
 disttype=centos
 if [ 1 -eq `grep -c 5[.]0 /etc/centos-release` ]; then
  vr=50
  cfgx=${cfgrhel50}
 elif [ 1 -eq `grep -c 5[.]1 /etc/centos-release` ]; then
  vr=51
  cfgx=${cfgrhel50}
 elif [ 1 -eq `grep -c 5[.]2 /etc/centos-release` ]; then
  vr=52
  cfgx=${cfgrhel50}
 elif [ 1 -eq `grep -c 5[.]3 /etc/centos-release` ]; then
  vr=53
  cfgx=${cfgrhel50}
 elif [ 1 -eq `grep -c 5[.]4 /etc/centos-release` ]; then
  vr=54
  cfgx=${cfgrhel50}
 elif [ 1 -eq `grep -c 5[.]5 /etc/centos-release` ]; then
  vr=55
  cfgx=${cfgrhel50}
 elif [ 1 -eq `grep -c 5[.]6 /etc/centos-release` ]; then
  vr=56
  cfgx=${cfgrhel56}
 elif [ 1 -eq `grep -c 5[.]7 /etc/centos-release` ]; then
  vr=57
  cfgx=${cfgrhel56}
 elif [ 1 -eq `grep -c 5[.]8 /etc/centos-release` ]; then
  vr=58
  cfgx=${cfgrhel56}
 elif [ 1 -eq `grep -c 5[.]10 /etc/centos-release` ]; then
  vr=510
  cfgx=${cfgrhel56}
 elif [ 1 -eq `grep -c 5[.]11 /etc/centos-release` ]; then
  vr=511
  cfgx=${cfgrhel56}
 elif [ 1 -eq `grep -c 6[.]0 /etc/centos-release` ]; then
  vr=60
  cfgx=${cfgrhel60}
 elif [ 1 -eq `grep -c 6[.]1 /etc/centos-release` ]; then
  vr=61
  cfgx=${cfgrhel60}
 elif [ 1 -eq `grep -c 6[.]2 /etc/centos-release` ]; then
  vr=62
  cfgx=${cfgrhel60}
 elif [ 1 -eq `grep -c 6[.]3 /etc/centos-release` ]; then
  vr=63
  cfgx=${cfgrhel60}
 elif [ 1 -eq `grep -c 6[.]4 /etc/centos-release` ]; then
  vr=64
  cfgx=${cfgrhel60}
 elif [ 1 -eq `grep -c 6[.]5 /etc/centos-release` ]; then
  vr=65
  cfgx=${cfgrhel60}
 elif [ 1 -eq `grep -c 6[.]6 /etc/centos-release` ]; then
  vr=66
  cfgx=${cfgrhel60}
 elif [ 1 -eq `grep -c 6[.]7 /etc/centos-release` ]; then
  vr=67
  cfgx=${cfgrhel60}
 elif [ 1 -eq `grep -c 6[.]8 /etc/centos-release` ]; then
  vr=68
  cfgx=${cfgrhel60}
 elif [ 1 -eq `grep -c 6[.]9 /etc/centos-release` ]; then
  vr=69
  cfgx=${cfgrhel60}
 elif [ 1 -eq `grep -c 7[.]0 /etc/centos-release` ]; then
  vr=70
  cfgx=${cfgrhel70}
 elif [ 1 -eq `grep -c 7[.]1 /etc/centos-release` ]; then
  vr=71
  cfgx=${cfgrhel70}
 elif [ 1 -eq `grep -c 7[.]2 /etc/centos-release` ]; then
  vr=72
  cfgx=${cfgrhel70}
 elif [ 1 -eq `grep -c 7[.]3 /etc/centos-release` ]; then
  vr=73
  cfgx=${cfgrhel70}
 elif [ 1 -eq `grep -c 7[.]4 /etc/centos-release` ]; then
  vr=74
  cfgx=${cfgrhel70}
 fi

#sles
elif [ -f /etc/SuSE-release ]; then
 disttype=sles
 if [ 1 -eq `grep -c 'VERSION = 10' /etc/SuSE-release` ]; then
  vr=10
  cfgx=${cfgsles10}
 elif [ 1 -eq `grep -c 'VERSION = 11' /etc/SuSE-release` ] && [ 1 -eq `grep -c 'PATCHLEVEL = 0' /etc/SuSE-release` ]; then
  vr=110
  cfgx=${cfgsles10}
 elif [ 1 -eq `grep -c 'VERSION = 11' /etc/SuSE-release` ] && [ 1 -eq `grep -c 'PATCHLEVEL = 1' /etc/SuSE-release` ]; then
  vr=111
  cfgx=${cfgsles11}
 elif [ 1 -eq `grep -c 'VERSION = 11' /etc/SuSE-release` ] && [ 1 -eq `grep -c 'PATCHLEVEL = 2' /etc/SuSE-release` ]; then
  vr=112
  cfgx=${cfgsles11}
 elif [ 1 -eq `grep -c 'VERSION = 11' /etc/SuSE-release` ] && [ 1 -eq `grep -c 'PATCHLEVEL = 3' /etc/SuSE-release` ]; then
  vr=113
  cfgx=${cfgsles11}
 elif [ 1 -eq `grep -c 'VERSION = 11' /etc/SuSE-release` ] && [ 1 -eq `grep -c 'PATCHLEVEL = 4' /etc/SuSE-release` ]; then
  vr=114
  cfgx=${cfgsles11}
 elif [ 1 -eq `grep -c 'VERSION = 12' /etc/SuSE-release` ] && [ 1 -eq `grep -c 'PATCHLEVEL = 0' /etc/SuSE-release` ]; then
  vr=120
  cfgx=${cfgsles12}
 elif [ 1 -eq `grep -c 'VERSION = 12' /etc/SuSE-release` ] && [ 1 -eq `grep -c 'PATCHLEVEL = 1' /etc/SuSE-release` ]; then
  vr=121
  cfgx=${cfgsles12}
 elif [ 1 -eq `grep -c 'VERSION = 12' /etc/SuSE-release` ] && [ 1 -eq `grep -c 'PATCHLEVEL = 2' /etc/SuSE-release` ]; then
  vr=122
  cfgx=${cfgsles12}
 elif [ 1 -eq `grep -c 'VERSION = 12' /etc/SuSE-release` ] && [ 1 -eq `grep -c 'PATCHLEVEL = 3' /etc/SuSE-release` ]; then
  vr=123
  cfgx=${cfgsles12}
 fi

#linx
elif [ -f /etc/linx-release ]; then
 disttype=linx
 if [ 1 -eq `grep -c -E "6.0.42" /etc/linx-release` ]; then
  vr=42
  cfgx=${cfglinx40}
 elif [ 1 -eq `grep -c -E "^6.0.60" /etc/linx-release` ]; then
  vr=60
  cfgx=${cfglinx60}
 elif [ 1 -eq `grep -c -E "^6.0.80" /etc/linx-release` ]; then
  vr=80
  cfgx=${cfglinx80}
 fi

#k-ux
elif [ -f /etc/inspur-release ]; then
 disttype=kux
 if [ 1 -eq `grep -c -E "K[-]UX 2[.]1" /etc/inspur-release` ]; then
  vr=21
  cfgx=${cfgkux2}
 elif [ 1 -eq `grep -c " 3[.]1" /etc/inspur-release` ]; then
  vr=31
  cfgx=${cfgkux3}
 fi

#rhel
elif [ -f /etc/redhat-release ]; then
 disttype=rhel
 if [ 1 -eq `grep -c  'release 5 ' /etc/redhat-release` ]; then
  vr=50
  cfgx=${cfgrhel50}
 elif [ 1 -eq `grep -c 'release 5[.]1 ' /etc/redhat-release` ]; then
  vr=51
  cfgx=${cfgrhel50}
 elif [ 1 -eq `grep -c 5[.]2 /etc/redhat-release` ]; then
  vr=52
  cfgx=${cfgrhel50}
 elif [ 1 -eq `grep -c 5[.]3 /etc/redhat-release` ]; then
  vr=53
  cfgx=${cfgrhel50}
 elif [ 1 -eq `grep -c 5[.]4 /etc/redhat-release` ]; then
  vr=54
  cfgx=${cfgrhel50}
 elif [ 1 -eq `grep -c 5[.]5 /etc/redhat-release` ]; then
  vr=55
  cfgx=${cfgrhel50}
 elif [ 1 -eq `grep -c 5[.]6 /etc/redhat-release` ]; then
  vr=56
  cfgx=${cfgrhel56}
 elif [ 1 -eq `grep -c 5[.]7 /etc/redhat-release` ]; then
  vr=57
  cfgx=${cfgrhel56}
 elif [ 1 -eq `grep -c 5[.]8 /etc/redhat-release` ]; then
  vr=58
  cfgx=${cfgrhel56}
 elif [ 1 -eq `grep -c 5[.]9 /etc/redhat-release` ]; then
  vr=59
  cfgx=${cfgrhel56}
 elif [ 1 -eq `grep -c 5[.]10 /etc/redhat-release` ]; then
  vr=510
  cfgx=${cfgrhel56}
 elif [ 1 -eq `grep -c 5[.]11 /etc/redhat-release` ]; then
  vr=511
  cfgx=${cfgrhel56}
 elif [ 1 -eq `grep -c 6[.]0 /etc/redhat-release` ]; then
  vr=60
  cfgx=${cfgrhel60}
 elif [ 1 -eq `grep -c 6[.]1 /etc/redhat-release` ]; then
  vr=61
  cfgx=${cfgrhel60}
 elif [ 1 -eq `grep -c 6[.]2 /etc/redhat-release` ]; then
  vr=62
  cfgx=${cfgrhel60}
 elif [ 1 -eq `grep -c 6[.]3 /etc/redhat-release` ]; then
  vr=63
  cfgx=${cfgrhel60}
 elif [ 1 -eq `grep -c 6[.]4 /etc/redhat-release` ]; then
  vr=64
  cfgx=${cfgrhel60}
 elif [ 1 -eq `grep -c 6[.]5 /etc/redhat-release` ]; then
  vr=65
  cfgx=${cfgrhel60}
 elif [ 1 -eq `grep -c 6[.]6 /etc/redhat-release` ]; then
  vr=66
  cfgx=${cfgrhel60}
 elif [ 1 -eq `grep -c 6[.]7 /etc/redhat-release` ]; then
  vr=67
  cfgx=${cfgrhel60}
 elif [ 1 -eq `grep -c 6[.]8 /etc/redhat-release` ]; then
  vr=68
  cfgx=${cfgrhel60}
 elif [ 1 -eq `grep -c 6[.]9 /etc/redhat-release` ]; then
  vr=69
  cfgx=${cfgrhel60}
 elif [ 1 -eq `grep -c 7[.]0 /etc/redhat-release` ]; then
  vr=70
  cfgx=${cfgrhel70}
 elif [ 1 -eq `grep -c 7[.]1 /etc/redhat-release` ]; then
  vr=71
  cfgx=${cfgrhel70}
 elif [ 1 -eq `grep -c 7[.]2 /etc/redhat-release` ]; then
  vr=72
  cfgx=${cfgrhel70}
 elif [ 1 -eq `grep -c 7[.]3 /etc/redhat-release` ]; then
  vr=73
  cfgx=${cfgrhel70}
 elif [ 1 -eq `grep -c 7[.]4 /etc/redhat-release` ]; then
  vr=74
  cfgx=${cfgrhel70}
 fi

#others
elif [ -f /etc/os-release ]; then
  disttype=`grep '^ID=' /etc/os-release | awk -F"=" '{print $2}'`
  vr=`grep '^VERSION_ID=' /etc/os-release | awk -F"=" '{print $2}' | tr -d \"`
  if [ ${disttype} = ubuntu ]; then
    if [ ${vr} = "16.04" ]; then
      cfgx=${cfgub16}
    fi
  fi
  
  if [ ${disttype} = kylin ]; then
    if [ ${vr} = "4.0.2" ]; then
      cfgx=${cfgkylin40}
    fi
  fi
fi

if [ -z "${disttype}" ]; then
 echo distribute type is not supported
 exit 2
fi

echo system is $osname $disttype $vr

if [ -z "${cfgx}" ]; then
 echo no config schema found
 exit 2
fi


#step 3, check multipath tool
toolpath=`which multipath`
if [ -z "${toolpath}" ]; then
 echo multipath-tool not installed, install it first.
 exit 3
fi


#step 4, modify /etc/multipath.conf
echo "${cfgx}" > ./mcstmpcfg.txt
date=`date +%Y%m%d`

# check if /etc/multipath.conf exist
if [ -f /etc/multipath.conf ]; then
 #check if devices segment exist
 if [ -n "`grep -E '^[[:blank:]]*devices' /etc/multipath.conf`" ]; then
  :
 else
  echo no devices segment in conf file, add it
  #sed -i.${date} -e '$a devices {\n}\n' /etc/multipath.conf
  echo "devices {
}" >> /etc/multipath.conf
 fi
 
 #comment blacklist
 #sed -i.${date} '/^[[:blank:]]*blacklist[[:blank:]]*{/, /^[[:blank:]]*}[[:blank:]]*$/{/^[[:blank:]]*devnode[[:blank:]]*\"[*]\"/s/^/#/g}' /etc/multipath.conf
 
 #comment "INSPUR MCS"
 #sed -i.${date} -e '/^[[:blank:]]*vendor[[:blank:]]*/{N; /INSPUR.*MCS/{s/^/#/g; s/\n/\n#/g; p}; d}' /etc/multipath.conf
 sed -i.${date} -e '/^[[:blank:]]*device[[:blank:]]*{/, /^[[:blank:]]*}[[:blank:]]*$/{:x; N; /[[:blank:]]*}[[:blank:]]*$/!bx; /{.*INSPUR.*MCS.*}/{s/^/#/g; s/\n/\n#/g; p; d}}' /etc/multipath.conf
else
 #create a new multipath.conf with devices{}
 echo "devices {
}" > /etc/multipath.conf
 echo multipath.conf do not exist, created it.
fi

sed -i.${date}  -e "/^[[:blank:]]\?devices[[:blank:]]\?{/r ./mcstmpcfg.txt" /etc/multipath.conf
rm -f ./mcstmpcfg.txt


#step 5, check module dm_multipath
if [ -z `lsmod | awk '{print $1}' | grep dm_multipath` ]; then
 echo loading dm_multipath...
 modprobe dm_multipath
fi

if [ -z `lsmod | awk '{print $1}' | grep dm_multipath` ]; then
 echo failed to load kernel module: dm_multipath, MPIO cannot function, please check the system.
fi 

#step 6, reload devmap
echo reload multipath config...
if [ ${disttype} = "centos" ] || [ ${disttype} = "rhel" ] || [ ${disttype} = "kux" ] || [ ${disttype} = "sles" ] || [ ${disttype} = "oraclelinux" ] || [ ${disttype} = "ubuntu" ] || [ ${disttype} = "kylin" ]; then
 service multipathd restart
elif [ ${disttype} = "linx" ]; then
 multipath -r
 multipath -ll
fi


#step 7, setup g2 device block layer scheduler to noop
echo adjust sd scheduler...
sleep 1
for md in /sys/block/dm*
do
 isg2=0
 if [ -d ${md} ]; then
  for path in ${md}/slaves/*
  do
   if [ -d ${path} ] && [ -f ${path}/device/vendor ] && [ `cat ${path}/device/vendor` = "INSPUR" ] && [ `cat ${path}/device/model` = "MCS" ]; then
    isg2=1
    echo noop > ${path}/queue/scheduler
   fi
  done
  if [ 1 -eq ${isg2} ] && [ -f ${md}/queue/scheduler ]; then
   echo noop > ${md}/queue/scheduler
  fi
 fi
done


echo done
exit 0
