##### 启动  
```bash
zookeeper-server-start.sh /usr/local/kafka/config/zookeeper.properties
```
##### 分区查看  
```bash
kafka-topics.sh --zookeeper 127.0.0.1:2181 --describe  --topic test
```
##### 分区扩容  
```bash
kafka-topics.sh --zookeeper 127.0.0.1:2181 -alter --partitions 3 --topic test
```