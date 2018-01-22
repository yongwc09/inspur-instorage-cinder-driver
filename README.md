INSPUR G2 Cinder J2N 驱动使用说明
=================================
本驱动包实现了从Juno版本到Newton版本G2存储的支持。

Juno版本到Newton版本OpenStack驱动部分变化影响
---------------------------------------------
- Juno -> kilo
	1. 公共包由openstack内部移到了外部维护，因此juno版本需要使用内部的，从kilo版本开始需要使用外部的包
- Kilo -> Liberty
	1. opt.min opt.max选项支持
	2. san.SanDriver继承关系修改。 但是对存储驱动影响不大
	3. create_export函数增加了connector参数
- Liberty -> Mitaka
	1. 增加 cinder/opts.py 文件，需要在opts.py文件中增加存储参数相关模块导入
- Mitaka -> Newton
- Newton -> Ocata
	1. AddFCZone修饰符名称改为add_fc_zone

使用说明
--------
本驱动包中定义了DRIVER_RUN_VERSION来设定当前驱动的运行OpenStack版本。以此作为依据确定驱动包中的条件选择。

安装与使用该驱动
----------------
1. 将驱动包放置到Cinder服务的目录中
   ```
   cp -rf cinder/volume/drivers/inspur [PATH/TO/CINDER]/volume/drivers
   ```
2. 从Mitaka版本开始需要将opts.py文件中的inspur模块导入部分同步到cinder/opts.py文件中
   导入部分增加如下模块导入命令
   ```
       from cinder.volume.drivers.inspur.instorage import instorage_common as \
           cinder_volume_drivers_inspur_instorage_instoragecommon
       from cinder.volume.drivers.inspur.instorage import instorage_iscsi as \
           cinder_volume_drivers_inspur_instorage_instorageiscsi
   ```
   注册部分增加
   ```
       cinder_volume_drivers_inspur_instorage_instoragecommon.
       instorage_mcs_opts,
       cinder_volume_drivers_inspur_instorage_instorageiscsi.
       instorage_mcs_iscsi_opts,
   ```
   具体可以通过对比原系统中opts.py文件与本包中opts.py文件来确定
3. 修改Cinder服务配置文件

   ```
   #修改enable_backends配置,增加INSTORAGE
   enable_backends=[OTHERS],INSTORAGE

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

   卷映射如需启用多路径，需要在nova.conf配置中增加如下配置
   ```
   [libvirt]
   iscsi_use_multipath = True
   ```

   同时multipath.conf配置文件中需要将user_friendly_names选项设置为no 
   ```
   defaults {
      user_friendly_names no
   }
   ```

4. 在OpenStack环境中增加卷类型
   ```
   cinder type-create inspur

   cinder type-key set volume_backend_name=INSTORAGE
   
   ```
   之后便可使用该卷类型创建卷
