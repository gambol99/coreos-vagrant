#
#   Author: Rohith (gambol99@gmail.com)
#   Date: 2015-01-19 10:59:21 +0000 (Mon, 19 Jan 2015)
#
#  vim:ts=2:sw=2:et
#
FROM centos:centos7
MAINTAINER Rohith <gambol99@gmail.com>

ADD config/startup.sh /startup.sh

RUN yum install -y java-1.7.0-openjdk-headless wget tar egrep
RUN wget -q -O - http://apache.mirrors.pair.com/zookeeper/zookeeper-3.4.6/zookeeper-3.4.6.tar.gz | tar -xzf - -C /opt \
    && mv /opt/zookeeper-3.4.6 /opt/zookeeper \
    && mkdir -p /var/lib/zookeeper \
    && chown root:root -R /opt/zookeeper \
    && chmod +x startup.sh

ADD config/zoo.cfg /opt/zookeeper/conf/zoo.cfg

ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64
WORKDIR /opt/zookeeper
VOLUME [ "/opt/zookeeper/conf", "/var/lib/zookeeper" ]

EXPOSE 2181 2888 3888

ENTRYPOINT [ "/startup.sh" ]
