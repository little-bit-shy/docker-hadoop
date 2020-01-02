#### 1533356676@qq.com

## Docker依赖搭建  
##### 安装docker  
如果你已安装可跳过此步骤  
bash docker.install  

##### 安装shyaml  
如果你已安装可跳过此步骤  
bash compose.install  

##### 启动docker   
systemctl start docker  

## Zookeeper集群搭建  
### 环境依赖  
首选准备3台服务器以备使用zookeeper1、zookeeper2 、zookeeper3  

### 修改配置文件  
修改zookeeper/instances.yml，配置集群信息，用于生成hosts、myid文件  

##### 依次启动环境（zookeeper1、zookeeper2、zookeeper3）  
bash zookeeper.sh  

## Hadoop集群搭建  
### 环境依赖  
首选准备3台服务器以备使用hadoop1、hadoop2 、hadoop3  

##### 免密码登陆秘钥替换
./hadoop/ssh下面默认有一份私钥、公钥，这里建议删除默认秘钥改为自己的私钥  
秘钥生成方法参考hadoop-key.sh脚本  

##### 修改配置文件
修改hadoop/instances.yml，配置集群信息，用于生成hosts文件  

##### 依次启动环境（hadoop1、hadoop2 、hadoop3）  
bash hadoop.sh
==注意下载链接可能存在失效情况注意替换，如果出现下载过慢也可使用迅雷
下载之后根据启动脚本修改文件名后放入/hadoop/tar/即可==
![avatar](/help/download.png)

#### Hadoop启动  
##### 初次启动环境初始化  
在hadoop1启动所有JournalNode：hadoop-daemons.sh start journalnode  
在hadoop1上格式化namenode数据：hdfs namenode -format  
在hadoop1上启动namenode：hadoop-daemon.sh start namenode  
在hadoop2 上执行同步namenode元数据：hdfs namenode -bootstrapStandby  
在hadoop2上启动namenode：hadoop-daemon.sh start namenode  
在hadoop1上初始化zkfc：hdfs zkfc -formatZK  
在hadoop1上停止业务：stop-dfs.sh  
在hadoop1上全面启动业务：start-all.sh  
至此hadoop2.x hdfs完全分布式 HA 搭建完毕  

##### 二次启动
无需重复初次启动时的频繁操作
在hadoop1上全面启动业务：start-all.sh  

#### Hive启动  
##### 修改Hive相关配置  
修改hive/hive-site.xml，配置MySQL用于储存Hive元数据  

##### 初次启动Hive元数据初始化  
在hadoop1上初始化元数据：schematool -initSchema -dbType mysql  

##### 启动Hive  
在hadoop1上启动：hiveserver2 &  
[Hive使用简介](/help/hive.md)
[PyHive使用简介](/help/python.md)

#### Hbase启动  
在hadoop1上启动：start-hbase.sh  

#### Sqoop启动  
##### 测试Sqoop功能  
```bash
sqoop \
list-databases \
--connect jdbc:mysql://localhost:3306/ \
--username root \
--password 123456
```
[Sqoop使用简介](/help/sqoop.md)

#### Kafka启动  
kafka-server-start.sh -daemon ${KAFKA_HOME}/config/server.properties  
[Kafka使用简介](/help/kafka.md)

#### Spark启动  
在hadoop1上启动：${SPARK_HOME}/sbin/start-all.sh  

#### Kylin启动  
在hadoop1启动mr-jobhistory：mr-jobhistory-daemon.sh start historyserver  
在hadoop1上启动：kylin.sh start  
初始用户名和密码为ADMIN/KYLIN  
