#!/bin/bash
#zookeeper启动

dir=$(cd `dirname $0`; pwd)

# 相关安装包下载
HADOOP_URL=https://www-us.apache.org/dist/hadoop/common/hadoop-2.9.2/hadoop-2.9.2.tar.gz
HIVE_URL=https://mirrors.tuna.tsinghua.edu.cn/apache/hive/hive-2.3.4/apache-hive-2.3.4-bin.tar.gz
SQOOP_URL=http://mirrors.hust.edu.cn/apache/sqoop/1.4.7/sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz
KAFKA_URL=https://mirrors.tuna.tsinghua.edu.cn/apache/kafka/2.2.0/kafka_2.11-2.2.0.tgz
HBASE_URL=https://mirrors.tuna.tsinghua.edu.cn/apache/hbase/1.4.9/hbase-1.4.9-bin.tar.gz
SPARK_URL=https://archive.apache.org/dist/spark/spark-2.4.3/spark-2.4.3-bin-hadoop2.7.tgz
SCALA_URL=https://downloads.lightbend.com/scala/2.12.8/scala-2.12.8.tgz
KYLIN_URL=https://mirrors.tuna.tsinghua.edu.cn/apache/kylin/apache-kylin-3.0.0-alpha/apache-kylin-3.0.0-alpha-bin-hbase1x.tar.gz

if [ ! -f "${dir}/hadoop/tar/hadoop.tar.gz" ];then
  wget ${HADOOP_URL} -O ${dir}/hadoop/tar/hadoop.tar.gz
fi
if [ ! -f "${dir}/hadoop/tar/hive.tar.gz" ];then
  wget ${HIVE_URL} -O ${dir}/hadoop/tar/hive.tar.gz
fi
if [ ! -f "${dir}/hadoop/tar/sqoop.tar.gz" ];then
  wget ${SQOOP_URL} -O ${dir}/hadoop/tar/sqoop.tar.gz
fi
if [ ! -f "${dir}/hadoop/tar/kafka.tgz" ];then
  wget ${KAFKA_URL} -O ${dir}/hadoop/tar/kafka.tgz
fi
if [ ! -f "${dir}/hadoop/tar/hbase.tar.gz" ];then
  wget ${HBASE_URL} -O ${dir}/hadoop/tar/hbase.tar.gz
fi
if [ ! -f "${dir}/hadoop/tar/spark.tgz" ];then
  wget ${HBASE_URL} -O ${dir}/hadoop/tar/spark.tgz
fi
if [ ! -f "${dir}/hadoop/tar/scala.tgz" ];then
  wget ${SCALA_URL} -O ${dir}/hadoop/tar/scala.tgz
fi
if [ ! -f "${dir}/hadoop/tar/kylin.tar.gz" ];then
  wget ${KYLIN_URL} -O ${dir}/hadoop/tar/kylin.tar.gz
fi

# 修改项目权限
chown 1000:1000 -R ${dir}/hadoop
chown 1000:1000 -R ${dir}/hive
chown 1000:1000 -R ${dir}/sqoop
chown 1000:1000 -R ${dir}/pyhive
chown 1000:1000 -R ${dir}/kafka
chown 1000:1000 -R ${dir}/hbase
chown 1000:1000 -R ${dir}/spark
chown 1000:1000 -R ${dir}/kylin
chmod 644 ${dir}/hadoop/known_hosts

# 创建容器hosts
: > ${dir}/hadoop/etc/hosts

if [ -f "/usr/sbin/ip" ]
then
  thisIps=(`ip addr | grep 'inet' | awk -F" " '{print $2}' | awk -F"/" '{print $1}'`)
elif [ -f "/usr/sbin/ifconfig" ]
then
  thisIps=(`ifconfig |grep "inet"|awk -F" " '{print $2}'`)
else
  echo -e "\033[31m 无法获取当前服务器IP地址，退出项目 \033[0m"
  exit
fi

length=`cat ${dir}/hadoop/instances.yml | shyaml get-length instances`

for((i=0;i<${length};i++));
do
  hostnameString=(`cat ${dir}/hadoop/instances.yml | shyaml get-value instances.${i}.hostname`)
  ipString=(`cat ${dir}/hadoop/instances.yml | shyaml get-value instances.${i}.ip`)
  dnsString=(`cat ${dir}/hadoop/instances.yml | shyaml get-value instances.${i}.dns`)
  hostname=${hostnameString[1]}
  ip=${ipString[1]}
  dns=${dnsString[1]}
  echo "${ip}   ${dns}" >> ${dir}/hadoop/etc/hosts
  for thisIp in ${thisIps[@]}
    do
      if [ "${thisIp}" == "${ip}" ] ;then
          if [ "${hostname}" == "true" ] ;then
              thisHostname=${dns}
          fi
          echo "${ip}   hadoop" >> ${dir}/hadoop/etc/hosts
      fi
    done
done

#############################hadoop
docker build --network host -t hadoop ${dir}/hadoop
docker rm $(docker ps -a| grep "hadoop" |cut -d " " -f 1) -f
docker run -d --name hadoop --net=host --hostname ${thisHostname} \
    -v ${dir}/hadoop/etc/hosts:/etc/hosts \
    -v ${dir}/hadoop/etc/hadoop:/usr/local/hadoop/etc/hadoop \
    -v ${dir}/hadoop/dfs:/usr/local/hadoop/dfs \
    -v ${dir}/hadoop/jn:/usr/local/hadoop/jn \
    -v ${dir}/hadoop/tmp:/usr/local/hadoop/tmp \
    -v ${dir}/hadoop/logs:/usr/local/hadoop/logs \
    -v ${dir}/hive/conf/hive-site.xml:/usr/local/hive/conf/hive-site.xml \
    -v ${dir}/hive/mysql-connector-java-5.1.47/mysql-connector-java-5.1.47.jar:/usr/local/hive/lib/mysql-connector-java-5.1.47.jar \
    -v ${dir}/sqoop/conf/sqoop-env.sh:/usr/local/sqoop/conf/sqoop-env.sh \
    -v ${dir}/sqoop/conf/sqoop-site.xml:/usr/local/sqoop/conf/sqoop-site.xml \
    -v ${dir}/sqoop/java-json-schema/java-json-schema.jar:/usr/local/sqoop/lib/java-json-schema.jar \
    -v ${dir}/sqoop/mysql-connector-java-5.1.47/mysql-connector-java-5.1.47.jar:/usr/local/sqoop/lib/mysql-connector-java-5.1.47.jar \
    -v ${dir}/pyhive:/usr/local/pyhive \
    -v ${dir}/kafka/config:/usr/local/kafka/config \
    -v ${dir}/kafka/kafka-logs:/usr/local/kafka/kafka-logs \
    -v ${dir}/kafka/logs:/usr/local/kafka/logs \
    -v ${dir}/hbase/logs:/usr/local/hbase/logs \
    -v ${dir}/hbase/conf:/usr/local/hbase/conf \
    -v ${dir}/hbase/tmp:/usr/local/hbase/tmp \
    -v ${dir}/hadoop/etc/hadoop/hdfs-site.xml:/usr/local/hbase/conf/hdfs-site.xml \
    -v ${dir}/spark/conf:/usr/local/spark/conf \
    -v ${dir}/spark/data:/usr/local/spark/data \
    -v ${dir}/spark/logs:/usr/local/spark/logs \
    -v ${dir}/kylin/conf:/usr/local/kylin/conf \
    -v ${dir}/kylin/logs:/usr/local/kylin/logs \
    hadoop