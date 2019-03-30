## Zookeeper集群搭建  
### 环境依赖  
首选准备3台服务器以备使用zookeeper1、zookeeper2 、zookeeper3  

##### 安装docker（zookeeper1、zookeeper2、zookeeper3）  
如果你已安装可跳过此步骤  
bash docker.install  

##### 安装shyaml（zookeeper1、zookeeper2、zookeeper3）  
如果你已安装可跳过此步骤  
bash compose.install  

##### 启动docker（zookeeper1、zookeeper2、zookeeper3）    
systemctl start docker  

### 修改配置文件  
修改zookeeper/instances.yml，配置集群信息，用于生成hosts、myid文件  
修改zookeeper/server.yml，配置当前主机信息，用于生成myid文件  

##### 依次启动环境（zookeeper1、zookeeper2、zookeeper3）  
bash zookeeper.sh  

## Hadoop集群搭建  
### 环境依赖  
首选准备3台服务器以备使用hadoop1、hadoop2 、hadoop3  

##### 安装docker（hadoop1、hadoop2 、hadoop3）  
如果你已安装可跳过此步骤  
bash docker.install  

##### 安装shyaml（hadoop1、hadoop2 、hadoop3）  
如果你已安装可跳过此步骤  
bash compose.install  

##### 启动docker（hadoop1、hadoop2 、hadoop3）    
systemctl start docker  

##### 免密码登陆秘钥替换
./hadoop/ssh下面默认有一份私钥、公钥，这里建议删除默认秘钥改为自己的私钥  
秘钥生成方法参考hadoop-key.sh脚本  

##### 修改配置文件
修改hadoop/instances.yml，配置集群信息，用于生成hosts文件  

##### 依次启动环境（hadoop1、hadoop2 、hadoop3）  
bash hadoop.sh  

##### 初次启动环境初始化  
首先切换用户：su hadoop  
在hadoop1启动所有JournalNode：hadoop-daemons.sh start journalnode  
在hadoop1上格式化namenode数据：hdfs namenode -format  
在hadoop1上启动namenode：hadoop-daemon.sh start namenode  
在hadoop2 上执行同步namenode元数据：hdfs namenode -bootstrapStandby  
在hadoop2上启动namenode：hadoop-daemon.sh start namenode  
在hadoop1上初始化zkfc：hdfs zkfc -formatZK  
在hadoop1上停止业务：stop-dfs.sh  
在hadoop1上全面启动业务：start-dfs.sh  
至此hadoop2.x hdfs完全分布式 HA 搭建完毕  

##### 二次启动
无需重复初次启动时的频繁操作  
在hadoop1上全面启动业务：start-dfs.sh  

###### 修改Hive相关配置  
修改hive/hive-site.xml，配置MySQL用于储存Hive元数据  

###### 初次启动Hive元数据初始化  
初始化元数据：schematool -initSchema -dbType mysql  

###### 启动Hive  
启动：hiveserver2 &