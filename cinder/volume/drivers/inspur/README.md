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
- Mitaka -> Newton

使用说明
--------
本驱动包中定义了DRIVER_RUN_VERSION来设定当前驱动的运行OpenStack版本。以此作为依据确定驱动包中的条件选择。
