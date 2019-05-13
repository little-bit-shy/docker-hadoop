FROM centos:7

ENV HADOOP_URL=https://www-us.apache.org/dist/hadoop/common/hadoop-2.9.2/hadoop-2.9.2.tar.gz
ENV HIVE_URL=https://mirrors.tuna.tsinghua.edu.cn/apache/hive/hive-2.3.4/apache-hive-2.3.4-bin.tar.gz
ENV SQOOP_URL=http://mirrors.hust.edu.cn/apache/sqoop/1.4.7/sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz
ENV KAFKA_URL=https://mirrors.tuna.tsinghua.edu.cn/apache/kafka/2.2.0/kafka_2.11-2.2.0.tgz
ENV HBASE_URL=https://mirrors.tuna.tsinghua.edu.cn/apache/hbase/1.4.9/hbase-1.4.9-bin.tar.gz

RUN yum install -y \
    wget \
    java-1.8.0-openjdk*

ENV SSH_PORT = 16022
ENV HADOOP_HOME /usr/local/hadoop
ENV HIVE_HOME /usr/local/hive
ENV PYHIVE_HOME /usr/local/pyhive
ENV KAFKA_HOME /usr/local/kafka
ENV HBASE_HOME /usr/local/hbase
ENV HADOOP_MAPRED_HOME $HADOOP_HOME
ENV SQOOP_HOME /usr/local/sqoop
ENV HADOOP_COMMON_HOME $HADOOP_HOME
ENV HADOOP_HDFS_HOME $HADOOP_HOME
ENV YARN_HOME $HADOOP_HOME
ENV HADOOP_COMMON_LIB_NATIVE_DIR $HADOOP_HOME/lib/native
ENV PATH $PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin:$HIVE_HOME/bin:$SQOOP_HOME/bin:$KAFKA_HOME/bin:$HBASE_HOME/bin
ENV HADOOP_INSTALL $HADOOP_HOME
ENV HADOOP_CLASSPATH $HADOOP_HOME/lib/*
ENV HADOOP_CLASSPATH $HADOOP_CLASSPATH:$HIVE_HOME/lib/*

# hadoop安装
RUN cd /tmp \
    && mkdir ${HADOOP_HOME} \
    && wget ${HADOOP_URL} \
    && tar -xzf /tmp/hadoop-2.9.2.tar.gz -C ${HADOOP_HOME} --strip-components=1 \
    && rm -f /tmp/hadoop-2.9.2.tar.gz

WORKDIR ${HADOOP_HOME}

RUN useradd hadoop \
    && chown hadoop:hadoop -R ${HADOOP_HOME}

# ssl安装（免密码登陆）
RUN yum install -y \
    which \
    openssh-server \
    openssh-clients

RUN mkdir /home/hadoop/.ssh \
    && chmod 700 /home/hadoop/.ssh
COPY ./ssh/id_rsa /home/hadoop/.ssh/id_rsa
COPY ./ssh/authorized_keys /home/hadoop/.ssh/authorized_keys
RUN chmod 600 /home/hadoop/.ssh/id_rsa
RUN chmod 600 /home/hadoop/.ssh/authorized_keys
RUN chown hadoop:hadoop /home/hadoop/.ssh -R

RUN echo "Port ${SSH_PORT}" >> /etc/ssh/sshd_config

RUN  ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ""
RUN  ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N ""
RUN  ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ""
COPY ./entrypoint.sh /tmp/entrypoint.sh
RUN chmod 777 /tmp/entrypoint.sh

# hive安装
RUN cd /tmp \
    && mkdir ${HIVE_HOME} \
    && wget ${HIVE_URL} \
    && tar -xzf /tmp/apache-hive-2.3.4-bin.tar.gz -C ${HIVE_HOME} --strip-components=1 \
    && rm -f /tmp/apache-hive-2.3.4-bin.tar.gz

# sqoop安装
RUN cd /tmp \
    && mkdir ${SQOOP_HOME} \
    && wget ${SQOOP_URL}   \
    && tar -xzf /tmp/sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz -C ${SQOOP_HOME} --strip-components=1 \
    && rm -f /tmp/sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz

RUN yum install -y epel-release \
    && yum install -y python-pip \
    && yum clean all

RUN yum install -y \
    gcc \
    gcc-c++ \
    python-devel \
    cyrus-sasl-devel

# pyhive安装
RUN pip install pyhive \
    && pip install sasl \
    && pip install thrift \
    && pip install thrift-sasl

RUN yum install -y \
    cyrus-sasl-plain \
    cyrus-sasl-devel \
    cyrus-sasl-gssapi

RUN chown hadoop:hadoop -R ${HIVE_HOME} \
    && chown hadoop:hadoop -R ${SQOOP_HOME} \
    && mkdir ${PYHIVE_HOME} \
    && chown hadoop:hadoop -R ${PYHIVE_HOME}

# kafka安装
RUN cd /tmp \
    && mkdir ${KAFKA_HOME} \
    && wget ${KAFKA_URL} \
    && tar -xzf /tmp/kafka_2.11-2.2.0.tgz -C ${KAFKA_HOME} --strip-components=1 \
    && rm -f /tmp/kafka_2.11-2.2.0.tgz \
    && chown hadoop:hadoop -R ${KAFKA_HOME}

# hbase安装
RUN cd /tmp \
    && mkdir ${HBASE_HOME} \
    && wget ${HBASE_URL} \
    && tar -xzf /tmp/hbase-1.4.9-bin.tar.gz -C ${HBASE_HOME} --strip-components=1 \
    && rm -f /tmp/hbase-1.4.9-bin.tar.gz \
    && chown hadoop:hadoop -R ${HBASE_HOME}

ENTRYPOINT  /tmp/entrypoint.sh