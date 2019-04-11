#!/usr/bin/python
# -*- coding: UTF-8 -*-

from pyhive import hive
import commands

# hive
HOST="hadoop"
PORT="10000"
USERNAME="hadoop"
DATABASE="default"
# mysql
MYSQL_HOST="192.168.253.129"
MYSQL_PORT="3306"
MYSQL_USERNAME="root"
MYSQL_PASSWORD="123456"
MYSQL_DATABASE="test"

######################## Data synchronization Mysql to Hive ########################
print '\033[1;32mStart data synchronization!!\033[0m'
(status, output) = commands.getstatusoutput("sqoop import \
--driver com.mysql.jdbc.Driver \
--connect jdbc:mysql://" + MYSQL_HOST + ":" + MYSQL_PORT + "/" + MYSQL_DATABASE + " \
--username " + MYSQL_USERNAME + " \
--password " + MYSQL_PASSWORD + " \
--table test \
--check-column time \
--incremental append \
--last-value '2018-08-09 15:30:29' \
--merge-key id \
--fields-terminated-by '\001' \
--lines-terminated-by '\n' \
--num-mappers 3 \
--target-dir /user/hive/warehouse/test \
--hive-drop-import-delims")

if status != 0:
    print '\033[1;31mData synchronization failure!!\033[0m'
    print output
    exit()
else:
    print '\033[1;32mData synchronization successful!!\033[0m'

######################## Data statistics Hive to Hive ########################
print '\033[1;32mStart data statistics!!\033[0m'
conn=hive.Connection(host=HOST, port=PORT, username=USERNAME,database=DATABASE)

cursor = conn.cursor()
cursor.execute("INSERT OVERWRITE TABLE test_out SELECT name,count(1),to_date(time) FROM test GROUP BY name,to_date(time)")
print '\033[1;32mData statistics successful!!\033[0m'
#cursor.execute("SELECT * FROM test")
#for result in cursor.fetchall():
#    print(result[2])

######################## Data synchronization Hive to Mysql ########################
print '\033[1;32mStart data synchronization!!\033[0m'
(status, output) = commands.getstatusoutput("sqoop export \
--driver com.mysql.jdbc.Driver \
--connect 'jdbc:mysql://" + MYSQL_HOST + ":" + MYSQL_PORT + "/" + MYSQL_DATABASE + "?useUnicode=true&characterEncoding=utf-8' \
--username " + MYSQL_USERNAME + " \
--password " + MYSQL_PASSWORD + " \
--table test_out \
--num-mappers 3 \
--export-dir /user/hive/warehouse/test_out \
--fields-terminated-by '\001' \
--lines-terminated-by '\n'")

if status != 0:
    print '\033[1;31mData synchronization failure!!\033[0m'
    print output
    exit()
else:
    print '\033[1;32mData synchronization successful!!\033[0m'