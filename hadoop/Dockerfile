FROM centos:7

ENV HADOOP_FILE=hadoop.tar.gz
ENV HIVE_FILE=hive.tar.gz
ENV SQOOP_FILE=sqoop.tar.gz
ENV KAFKA_FILE=kafka.tgz
ENV HBASE_FILE=hbase.tar.gz
ENV SPARK_FILE=spark.tgz
ENV SCALA_FILE=scala.tgz

RUN yum install -y \
    wget \
    java-1.8.0-openjdk*

ENV SSH_PORT = 16022
ENV HADOOP_HOME /usr/local/hadoop
ENV HIVE_HOME /usr/local/hive
ENV PYHIVE_HOME /usr/local/pyhive
ENV KAFKA_HOME /usr/local/kafka
ENV HBASE_HOME /usr/local/hbase
ENV SPARK_HOME /usr/local/spark
ENV SCALA_HOME /usr/local/scala
ENV HADOOP_MAPRED_HOME $HADOOP_HOME
ENV SQOOP_HOME /usr/local/sqoop
ENV HADOOP_COMMON_HOME $HADOOP_HOME
ENV HADOOP_HDFS_HOME $HADOOP_HOME
ENV YARN_HOME $HADOOP_HOME
ENV HADOOP_COMMON_LIB_NATIVE_DIR $HADOOP_HOME/lib/native
ENV PATH $PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin:$HIVE_HOME/bin:$SQOOP_HOME/bin:$KAFKA_HOME/bin:$HBASE_HOME/bin:$SPARK_HOME/bin:$SCALA_HOME/bin
ENV HADOOP_INSTALL $HADOOP_HOME
ENV HADOOP_CLASSPATH $HADOOP_HOME/lib/*
ENV HADOOP_CLASSPATH $HADOOP_CLASSPATH:$HIVE_HOME/lib/*

# hadoop安装
COPY ./tar/${HADOOP_FILE} /tmp/${HADOOP_FILE}
RUN cd /tmp \
    && mkdir ${HADOOP_HOME} \
    && tar -xzf /tmp/${HADOOP_FILE} -C ${HADOOP_HOME} --strip-components=1 \
    && rm -f /tmp/${HADOOP_FILE}

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
COPY ./tar/${HIVE_FILE} /tmp/${HIVE_FILE}
RUN cd /tmp \
    && mkdir ${HIVE_HOME} \
    && tar -xzf /tmp/${HIVE_FILE} -C ${HIVE_HOME} --strip-components=1 \
    && rm -f /tmp/${HIVE_FILE}

# sqoop安装
COPY ./tar/${SQOOP_FILE} /tmp/${SQOOP_FILE}
RUN cd /tmp \
    && mkdir ${SQOOP_HOME} \
    && tar -xzf /tmp/${SQOOP_FILE} -C ${SQOOP_HOME} --strip-components=1 \
    && rm -f /tmp/${SQOOP_FILE}

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
COPY ./tar/${KAFKA_FILE} /tmp/${KAFKA_FILE}
RUN cd /tmp \
    && mkdir ${KAFKA_HOME} \
    && tar -xzf /tmp/${KAFKA_FILE} -C ${KAFKA_HOME} --strip-components=1 \
    && rm -f /tmp/${KAFKA_FILE} \
    && chown hadoop:hadoop -R ${KAFKA_HOME}

# hbase安装
COPY ./tar/${HBASE_FILE} /tmp/${HBASE_FILE}
RUN cd /tmp \
    && mkdir ${HBASE_HOME} \
    && tar -xzf /tmp/${HBASE_FILE} -C ${HBASE_HOME} --strip-components=1 \
    && rm -f /tmp/${HBASE_FILE} \
    && chown hadoop:hadoop -R ${HBASE_HOME}

# sqark安装
COPY ./tar/${SPARK_FILE} /tmp/${SPARK_FILE}
RUN cd /tmp \
    && mkdir ${SPARK_HOME} \
    && tar -xzf /tmp/${SPARK_FILE} -C ${SPARK_HOME} --strip-components=1 \
    && rm -f /tmp/${SPARK_FILE} \
    && chown hadoop:hadoop -R ${SPARK_HOME}

# scala安装
COPY ./tar/${SCALA_FILE} /tmp/${SCALA_FILE}
RUN cd /tmp \
    && mkdir ${SCALA_HOME} \
    && tar -xzf /tmp/${SCALA_FILE} -C ${SCALA_HOME} --strip-components=1 \
    && rm -f /tmp/${SCALA_FILE}

ENTRYPOINT  /tmp/entrypoint.sh