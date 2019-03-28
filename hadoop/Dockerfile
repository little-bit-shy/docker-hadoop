FROM centos:7

RUN yum install -y \
    wget \
    java-1.8.0-openjdk*

ENV HADOOP_HOME /usr/local/hadoop
ENV HADOOP_MAPRED_HOME $HADOOP_HOME
ENV HADOOP_COMMON_HOME $HADOOP_HOME
ENV HADOOP_HDFS_HOME $HADOOP_HOME
ENV YARN_HOME $HADOOP_HOME
ENV HADOOP_COMMON_LIB_NATIVE_DIR $HADOOP_HOME/lib/native
ENV PATH $PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin
ENV HADOOP_INSTALL $HADOOP_HOME

RUN cd /tmp \
    && mkdir /usr/local/hadoop \
    && wget http://mirrors.shu.edu.cn/apache/hadoop/common/hadoop-2.9.2/hadoop-2.9.2.tar.gz \
    && tar -xzf /tmp/hadoop-2.9.2.tar.gz -C /usr/local/hadoop --strip-components=1 \
    && rm -f /tmp/hadoop-2.9.2.tar.gz

WORKDIR /usr/local/hadoop

RUN useradd hadoop \
    && chown hadoop:hadoop -R /usr/local/hadoop

RUN yum install -y \
    which \
    openssh-server \
    openssh-clients

RUN mkdir /home/hadoop/.ssh \
    && chmod 700 /home/hadoop/.ssh
COPY ./ssh/id_rsa /home/hadoop/.ssh/id_rsa
COPY ./ssh/authorized_keys /home/hadoop/.ssh/authorized_keys
RUN chmod 600 /home/hadoop/.ssh/authorized_keys
RUN chown hadoop:hadoop /home/hadoop/.ssh -R

RUN echo "Port 16022" >> /etc/ssh/sshd_config

RUN  ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ""
RUN  ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N ""
RUN  ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ""

#ENTRYPOINT ["/usr/sbin/sshd"]
CMD ["/usr/sbin/init"]