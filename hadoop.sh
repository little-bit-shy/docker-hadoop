#!/bin/bash
#zookeeper启动

dir=/usr/local/hadoop

# 修改项目权限
chown 1000:1000 -R ${PWD}/hadoop
chmod 644 ${PWD}/hadoop/known_hosts

# 创建容器hosts
: > ${dir}/hadoop/etc/hosts

if [ -f "/usr/sbin/ip" ]
then
  thisIps=(`ip addr | grep 'inet' | awk -F" " '{print $2}' | awk -F"/" '{print $1}'`)
elif [ -f "/usr/sbin/ifconfig" ]
then
  thisIps=(`ifconfig |grep "inet"|awk -F" " '{print $2}'`)
else
  echo -e “\033[31m 无法获取当前服务器IP地址，退出项目 \033[0m”
  exit
fi

length=`cat ${dir}/hadoop/instances.yml | shyaml get-length instances`

for((i=0;i<${length};i++));
do
  ipString=(`cat ${dir}/hadoop/instances.yml | shyaml get-value instances.${i}.ip`)
  dnsString=(`cat ${dir}/hadoop/instances.yml | shyaml get-value instances.${i}.dns`)
  ip=${ipString[1]}
  dns=${dnsString[1]}
  echo "${ip}   ${dns}" >> ${dir}/hadoop/etc/hosts
  for thisIp in ${thisIps[@]}
    do
      if [ "${thisIp}" == "${ip}" ] ;then
          echo "${ip}   hadoop" >> ${dir}/hadoop/etc/hosts
      fi
    done
done

#############################hadoop
docker build --network host -t hadoop ${dir}/hadoop
docker rm $(docker ps -a| grep "hadoop" |cut -d " " -f 1) -f
docker run -d --name hadoop --net=host  \
    -v ${dir}/hadoop/known_hosts:/home/hadoop/.ssh/known_hosts \
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
    hadoop