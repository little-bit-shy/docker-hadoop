#!/bin/bash
#zookeeper启动

dir=/usr/local/hadoop

# 创建容器hosts
: > ${dir}/zookeeper/etc/hosts
myid=0
servers=""
length=`cat ${dir}/zookeeper/instances.yml | shyaml get-length instances`
thisServerIpString=(`cat ${dir}/zookeeper/server.yml | shyaml get-value server.0.ip`)
thisServerIp=${thisServerIpString[1]}
for((i=0;i<${length};i++));
do
  ipString=(`cat ${dir}/zookeeper/instances.yml | shyaml get-value instances.${i}.ip`)
  dnsString=(`cat ${dir}/zookeeper/instances.yml | shyaml get-value instances.${i}.dns`)
  idString=(`cat ${dir}/zookeeper/instances.yml | shyaml get-value instances.${i}.id`)
  ip=${ipString[1]}
  dns=${dnsString[1]}
  id=${idString[1]}
  echo "${ip}   ${dns}" >> ${dir}/zookeeper/etc/hosts
  servers="${servers}server.${id}=${dns}:2888:3888 "
  # 判断zookeeper服务id
  if [ "${thisServerIp}" == "${ip}" ] ;then
    myid=${id}
  fi
done

#############################启动zookeeper
# 如果使用环境变量来定义相关配置则不应挂载zoo.cfg脚本，系统会通过环境变量生成zoo.cfg配置文件
docker pull zookeeper:3.4.13
docker rm $(docker ps -a| grep "zookeeper" |cut -d " " -f 1) -f
docker run -d --name zookeeper --net=host \
    -v ${dir}/zookeeper/etc/hosts:/etc/hosts \
    -v ${dir}/zookeeper/datalog:/datalog \
    -v ${dir}/zookeeper/logs:/logs \
    -v ${dir}/zookeeper/data:/data \
    -e ZOO_MY_ID=${myid} \
    -e ZOO_SERVERS="${servers}" \
    zookeeper:3.4.13