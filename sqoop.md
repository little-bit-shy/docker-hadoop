#####测试  
```bash
/usr/local/sqoop/bin/sqoop \
list-databases \
--connect jdbc:mysql://hadoop001:3306/ \
--username root \
--password 123456
```
#####mysql导入hive
```bash
# mysql全表导入hive
bin/sqoop import \
--driver com.mysql.jdbc.Driver \
--connect jdbc:mysql://hadoop001:3306/hadoop \
--username root \
--password 123456 \
--table test \
--fields-terminated-by '\001' \
--lines-terminated-by '\n' \
--delete-target-dir \
--num-mappers 1 \
--hive-import \
--hive-database default \
--hive-table test \
--direct

# mysql导入hive增量更新
bin/sqoop import \
--driver com.mysql.jdbc.Driver \
--connect jdbc:mysql://hadoop001:3306/hadoop \
--username root \
--password 123456 \
--table test \
--check-column time \
--incremental lastmodified \
--last-value '2018-08-09 15:30:29' \
--merge-key id \
--fields-terminated-by '\001' \
--lines-terminated-by '\n' \
--num-mappers 1 \
--target-dir /user/hive/warehouse/test \
--hive-drop-import-delims # --hive-delims-replacement '-'
```

#####job机制
```bash
# 添加一个增量更新job
bin/sqoop job --create test -- \
import \
--driver com.mysql.jdbc.Driver \
--connect jdbc:mysql://hadoop001:3306/hadoop \
--username root \
--password 123456 \
--table test \
--check-column time \
--incremental lastmodified \
--last-value '2018-08-09 15:30:29' \
--merge-key id \
--fields-terminated-by '\001' \
--lines-terminated-by '\n' \
--num-mappers 1 \
--target-dir /user/hive/warehouse/test
```
执行job  
```bash
bin/sqoop job --exec test
```
再次执行job后查看数据已被更新  
查看job  
```bash
bin/sqoop job --show test

Job: test
Tool: import
Options:
----------------------------
verbose = false
hcatalog.drop.and.create.table = false
# sqoop会自动帮你记录last-value并更新，这使得增量更新变得相当简便
incremental.last.value = 2018-08-10 03:51:47.0
db.connect.string = jdbc:mysql://hadoop001:3306/hadoop
codegen.output.delimiters.escape = 0
codegen.output.delimiters.enclose.required = false
codegen.input.delimiters.field = 0
mainframe.input.dataset.type = p
split.limit = null
hbase.create.table = false
db.require.password = false
skip.dist.cache = false
hdfs.append.dir = false
db.table = test
codegen.input.delimiters.escape = 0
db.password = 123456
accumulo.create.table = false
import.fetch.size = null
codegen.input.delimiters.enclose.required = false
db.username = root
reset.onemapper = false
codegen.output.delimiters.record = 10
import.max.inline.lob.size = 16777216
sqoop.throwOnError = false
hbase.bulk.load.enabled = false
hcatalog.create.table = false
db.clear.staging.table = false
incremental.col = time
codegen.input.delimiters.record = 0
enable.compression = false
hive.overwrite.table = false
hive.import = false
codegen.input.delimiters.enclose = 0
accumulo.batch.size = 10240000
hive.drop.delims = false
customtool.options.jsonmap = {}
codegen.output.delimiters.enclose = 0
hdfs.delete-target.dir = false
codegen.output.dir = .
codegen.auto.compile.dir = true
relaxed.isolation = false
mapreduce.num.mappers = 1
accumulo.max.latency = 5000
import.direct.split.size = 0
sqlconnection.metadata.transaction.isolation.level = 2
codegen.output.delimiters.field = 9
export.new.update = UpdateOnly
incremental.mode = DateLastModified
hdfs.file.format = TextFile
sqoop.oracle.escaping.disabled = true
codegen.compile.dir = /tmp/sqoop-hadoop/compile/028365970856b88aa0aa91435ff172e5
direct.import = false
temporary.dirRoot = _sqoop
hdfs.target.dir = /user/hive/warehouse/test
hive.fail.table.exists = false
merge.key.col = id
jdbc.driver.class = com.mysql.jdbc.Driver
db.batch = false
```
==通常情况下，我们可以结合sqoop job和crontab等任务调度工具实现相关业务==  
#####hive导出到mysql
```bash
bin/sqoop export \
--driver com.mysql.jdbc.Driver \
--connect "jdbc:mysql://hadoop001:3306/hadoop?useUnicode=true&characterEncoding=utf-8" \
--username root \
--password 123456 \
--table test_out \
--num-mappers 1 \
--export-dir /user/hive/warehouse/test_out \
--fields-terminated-by '\001' \
--lines-terminated-by '\n'
```