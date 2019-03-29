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
修改hadopo/instances.yml，配置集群信息，用于生成hosts文件  

##### 依次启动环境（hadoop1、hadoop2 、hadoop3）  
bash hadoop.sh  

##### 初次启动环境初始化  
启动所有JournalNode：hadoop-daemons.sh start journalnode  
在其中任意一个namenode上格式化namenode数据：hdfs namenode -format  
启动刚刚格式化的namenode：hadoop-daemons.sh start namenode  
在任一没有格式化的namenode上执行同步元数据：hdfs namenode -bootstrapStandby  
启动第二个namenode  
在其中一个namenode上初始化zkfc：hdfs zkfc -formatZK  
停止上面节点：stop-dfs.sh  
全面启动：start-dfs.sh  
至此hadoop2.x hdfs完全分布式 HA 搭建完毕  