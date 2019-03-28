#!/bin/bash
#hadoop集群免密码登陆秘钥生成

dir=.

ssh-keygen -t rsa -f "${dir}/hadoop/ssh/id_rsa"

cat ${dir}/hadoop/ssh/id_rsa.pub > ${dir}/hadoop/ssh/authorized_keys