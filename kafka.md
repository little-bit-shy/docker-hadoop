##### 创建主题  
```bash
kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic test
```
##### 分区查看  
```bash
kafka-topics.sh --zookeeper localhost:2181 --describe  --topic test
```
##### 分区扩容  
```bash
kafka-topics.sh --zookeeper localhost:2181 -alter --partitions 3 --topic test
```