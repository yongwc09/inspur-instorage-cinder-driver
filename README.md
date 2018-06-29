INSPUR InStorage Cinder 驱动使用说明
=================================
本驱动包实现了从Juno版本到Queens版本对 InStorage 存储的支持。

Juno版本到Queens版本OpenStack驱动部分变化影响
---------------------------------------------
- Juno -> kilo
	1. 公共包由openstack内部移到了外部维护，因此juno版本需要使用内部的，从kilo版本开始需要使用外部的包
- Kilo -> Liberty
	1. opt.min opt.max选项支持
	2. san.SanDriver继承关系修改。 但是对存储驱动影响不大
	3. create_export函数增加了connector参数
- Liberty -> Mitaka
	1. 增加 cinder/opts.py 文件，需要在opts.py文件中增加存储参数相关模块导入
	2. 增加 cinder/coordination.py 文件，但是该文件中synchronized锁需要其他操作，暂时不使用。
- Mitaka -> Newton
- Newton -> Ocata
	1. AddFCZone修饰符名称改为add_fc_zone
	2. FC, iSCSI驱动中的synchronized锁由utils.py中定义改为使用coordination.py中的定义

使用说明
--------
本驱动包中定义了DRIVER_RUN_VERSION来设定目标OpenStack环境的版本。以此作为依据确定驱动包中的条件选择。
可以利用 mkpackage.sh 工具来生成指定OpenStack版本对应的包。
   - 可以通过 -h 参数获取 mkpackage.sh 的帮助信息
   ```
   ci@devstack-32:~/Cinder_V4.0.0.Build20180228$ ./mkpackage.sh -h
   Usage: ./mkpackage.sh [-h | -v | -t [j|k|l|m|o|p|q]]

   A tool to generate the package of inspur instorage cinder driver for specify Openstack version

   Options:
       -h    show this help
       -v    show the version
       -t V  specify the openstack version which
             we want generate package for, now we
             support version j k l m n o p q
   ```
   - 可以通过 -t 参数指定OpenStack目标版本, 已生成Ocata版本为例，如下所示
   ```
   ci@devstack-32:~/Cinder_V4.0.0.Build20180228$ ./mkpackage.sh -t o
   Generate Package for OpenStack version OCATA

   ci@devstack-32:~/Cinder_V4.0.0.Build20180228$ ls
   cinder  instorage_mpio_cfg.sh  InStorage_OCATA_cinder  mkpackage.sh  README.md
   ```
   其中 InStorage_OCATA_cinder 即为目标OpenStack版本对应的InStorage驱动文件包。将目录中驱动文件拷贝到指定位置即可。

   针对双活场景下的配置，请参考doc目录下的support-for-active-active.md文档。

安装与使用该驱动
----------------
1. 执行 ./mkpackage.sh -t X 生成X版本OpenStack对应的驱动包。X 为 OpenStack 对应版本首字母。
   ```
   ./mkpackage.sh -t X
   ```
2. 将生成驱动包中的inspur目录放置到cinder服务安装目录的驱动插件目录下.
   ```
   cp -rf InStorage_XXX_cinder/inspur [PATH/TO/CINDER]/volume/drivers
   ```
3. 从Mitaka版本开始, Cinder服务中增加了opts.py文件，该文件包含了配置参数相关的处理。需要使用驱动包中的opts.py文件替换cinder服务安装目录的opts.py文件中
   ```
   cp -rf InStorage_XXX_cinder/opts.py [PATH/TO/CINDER]/opts.py
   ```
4. 修改相关服务配置文件(所有配置改动均需要重启对应服务来使的新配置生效)

   a. Cinder服务配置 /etc/cinder/cinder.conf
      ```
      #修改enabled_backends配置,增加INSTORAGE
      enabled_backends=[OTHERS],INSTORAGE

      #增加存储后端，FC或者iSCSI方式连接

      [INSTORAGE]
      #FC连接驱动
      volume_driver=cinder.volume.drivers.inspur.instorage.instorage_fc.InStorageMCSFCDriver
      #存储的IP地址
      san_ip = 192.168.1.1 
      #存储管理员用户名
      san_login = [SUPERUSER]
      #存储管理员用户密码
      san_password = [PASSWORD]
      #存储池
      instorage_mcs_volpool_name = Pool0
      #后端名称
      volume_backend_name = INSTORAGE
      #拷贝镜像启用多路径
      #use_multipath_for_image_xfer = True

      [INSTORAGE]
      #iSCSI连接驱动
      volume_driver=cinder.volume.drivers.inspur.instorage.instorage_iscsi.InStorageMCSISCSIDriver
      #存储的IP地址
      san_ip = 192.168.1.1 
      #存储管理员用户名
      san_login = [SUPERUSER]
      #存储管理员用户密码
      san_password = [PASSWORD]
      #存储池
      instorage_mcs_volpool_name = Pool0
      #后端名称
      volume_backend_name = INSTORAGE
      #拷贝镜像启用多路径
      #use_multipath_for_image_xfer = True
      ```

   b. 使用多路径配置
      卷映射如需启用多路径，需要在nova.conf配置中增加如下配置
      ```
      [libvirt]
      volume_use_multipath = True
      ```
      或
      ```
      [libvirt]
      iscsi_use_multipath = True
      ```
      具体参数请参考OpenStack手册，不同版本使用的参数不一样。

      同时multipath.conf配置文件中需要将user_friendly_names选项设置为no 
      ```
      defaults {
         user_friendly_names no
      }
      ```

      针对 InStorage 存储，不同版本的主机系统多路径配置需要进行适当的优化，使得InStorage存储可以更好的支持多路径. instorage_mpio_cfg.sh 工具可以自动的识别操作系统，并对/etc/multipath.conf文件进行优化，增加InStorage存储的device部分。
      ```
      ./instorage_mpio_cfg.sh
      ```

5. 在OpenStack环境中增加卷类型
   ```
   cinder type-create inspur

   cinder type-key set volume_backend_name=INSTORAGE
   
   ```
   之后便可使用该卷类型创建卷
