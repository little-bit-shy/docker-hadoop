```bash
# 创建表事例
CREATE TABLE IF NOT EXISTS test (
id int
,uid int
,title string
,name string
,status int
,time timestamp)
COMMENT '简介'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY "\001"
LINES TERMINATED BY "\n"
STORED AS TEXTFILE;

CREATE TABLE IF NOT EXISTS test_out (
name string
, count int
,time date)
COMMENT '简介'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\001'
LINES TERMINATED BY '\n'
STORED AS TEXTFILE;

# 统计后将结果数据加入另一个表
INSERT INTO TABLE 
test_out(name,count,time) 
SELECT name,count(1),to_date(time) 
FROM test 
GROUP BY name,to_date(time);

INSERT OVERWRITE 
TABLE test_out
SELECT name,count(1),to_date(time) 
FROM test 
GROUP BY name,to_date(time);
```