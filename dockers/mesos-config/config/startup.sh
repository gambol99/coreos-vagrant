#!/bin/bash
#
#   Author: Rohith (gambol99@gmail.com)
#   Date: 2015-01-19 10:59:34 +0000 (Mon, 19 Jan 2015)
#
#  vim:ts=2:sw=2:et
#
VERSION="3.4.6"
NAME="Zookeeper ${VERSION}"

SERVICE_DELAY="5"
ZOO_DIR="/opt/zookeeper"
ZOO_HOST=${HOST:-""}
ZOO_ID=${ZOO_ID:-""}
ZOO_CONFIG="${ZOO_DIR}/conf/zoo.cfg"
ZOO_PORT_CLIENT=${ZOO_PORT_CLIENT:-2181}
ZOO_PORT_FOLLOWER=${ZOO_PORT_FOLLOWER:-2888}
ZOO_PORT_SERVER=${ZOO_PORT_SERVER:-3888}

annonce() {
  [ -n "$1" ] && echo "** $1"
}

failed() {
  [ -n "$1" ] && { annonce "[failed] $1"; exit 1; }
}

annonce "Generating the ${NAME} configuration: ${ZOO_CONFIG}"

# step: if we have a cluster, lets template them
if [ -n "${ZOO_SERVERS}" ]; then
  # step: we need to add myid
  ZOO_ID=$(echo ${ZOO_HOST} | egrep -o '[0-9]{3}')
  annonce "The zookeeper id for this host: ${ZOO_ID}"
  [ -z "${ZOO_ID}" ] && failed "You have not specified the zookeeper id for this server"
  echo "${ZOO_ID}" > "/var/lib/zookeeper/myid"

  echo "# Cluster configuration" >> ${ZOO_CONFIG}
  # server: <ID>:<IP> i.e. 101:10.241.171
  for SERVER in $(echo "${ZOO_SERVERS}" | tr ',' '\n'); do
    ID=${SERVER%%:*}
    IPADDRESS=${SERVER##*:}
    echo "server.${ID}=${IPADDRESS}:${ZOO_PORT_FOLLOWER}:${ZOO_PORT_SERVER}" >> ${ZOO_CONFIG}
  done
fi

# step: show the configuration for debugging purposed
annonce "Generated configuration for ${NAME}"
cat ${ZOO_CONFIG}

# step: go to sleep for x seconds
annonce "Sleeping for ${SERVICE_DELAY} seconds before starting the service"
sleep ${SERVICE_DELAY}

annonce "Starting the Zookeeper Service"
${ZOO_DIR}/bin/zkServer.sh start-foreground
