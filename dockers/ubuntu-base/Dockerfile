#
#   Author: Rohith (gambol99@gmail.com)
#   Date: 2014-10-24 13:33:33 +0100 (Fri, 24 Oct 2014)
#
#  vim:ts=2:sw=2:et
#
FROM ubuntu
MAINTAINER <gambol99@gmail.com>
RUN apt-get update
RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y build-essential && \
  apt-get install -y software-properties-common && \
  apt-get install -y byobu curl git htop man unzip vim wget supervisor && \
  rm -rf /var/lib/apt/lists/*
