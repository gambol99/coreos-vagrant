#
#   Author: Rohith (gambol99@gmail.com)
#   Date: 2015-01-15 15:14:33 +0000 (Thu, 15 Jan 2015)
#
#  vim:ts=2:sw=2:et
#
FROM centos:latest
MAINTAINER Rohith <gambol99@gmail.com>

ADD config/elasticsearch.repo /etc/yum.repos.d/elasticsearch.repo
ADD config/elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml
ADD config/startup.sh /startup.sh

RUN rpm --import https://packages.elasticsearch.org/GPG-KEY-elasticsearch
RUN yum install -y java-1.7.0-openjdk.x86_64 elasticsearch

VOLUME /data
EXPOSE 9200
EXPOSE 9300

WORKDIR /data

CMD [ "/startup.sh" ]

