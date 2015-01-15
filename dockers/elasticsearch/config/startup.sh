#!/bin/bash
#
#   Author: Rohith (gambol99@gmail.com)
#   Date: 2015-01-15 15:24:24 +0000 (Thu, 15 Jan 2015)
#
#  vim:ts=2:sw=2:et
#
VERSION="1.4.1"
NAME="Elasticsearch ${VERSION}"
SERVICE_DELAY=${SERVICE_DELAY:-5}

annonce() {
  echo "* $@"
}

annonce "Waiting for ${SERVICE_DELAY} seconds before starting up ${NAME}"
sleep ${SERVICE_DELAY}

annonce "Starting ${NAME} service"
/usr/share/elasticsearch/bin/elasticsearch
