#!/bin/bash
#
#   Author: Rohith (gambol99@gmail.com)
#   Date: 2015-01-15 15:24:24 +0000 (Thu, 15 Jan 2015)
#
#  vim:ts=2:sw=2:et
#
annonce() {
  echo "* $@"
}

VERSION="1.4.1"
NAME="Elasticsearch ${VERSION}"
SERVICE_DELAY=${SERVICE_DELAY:-5}
JAVA_OPTS=${JAVA_OPTS:-""}
JAVA_OPTS="-Des.transport.publish_host=${HOST} \
  -Des.transport.publish_port=${PORT_9300}"

[ -n "${CLUSTER}"   ] && JAVA_OPTS="${JAVA_OPTS} -Des.cluster.name=${CLUSTER}"
[ -n "${NODE_NAME}" ] && JAVA_OPTS="${JAVA_OPTS} -Des.node.name=${NODE_NAME}"

if [ -n "${PLUGINS}" ]; then
  while read plugin; do
    annonce "Installing the plugin: ${plugin}"
    /usr/share/elasticsearch/bin/plugin -install ${plugin}
  done < <(echo ${PLUGINS} | tr "," "\n")
fi

annonce "Waiting for ${SERVICE_DELAY} seconds before starting up ${NAME}"
sleep ${SERVICE_DELAY}

[ -n "${CONFIG}"    ] && {
  annonce "Elasticsearch configuration";
  cat ${CONFIG};
}

annonce "Starting ${NAME} service"
annonce "JAVA_OPTS: ${JAVA_OPTS}"

/usr/share/elasticsearch/bin/elasticsearch ${JAVA_OPTS}
