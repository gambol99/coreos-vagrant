#!/bin/bash
#
#   Author: Rohith (gambol99@gmail.com)
#   Date: 2014-11-21 16:48:39 +0000 (Fri, 21 Nov 2014)
#
#  vim:ts=2:sw=2:et
#

INTERFACE=${PROXY_INTERFACE:-eth0}
VERBOSE=${VERBOSE:-0}

if [ -z "$DISCOVERY" ]; then
  echo "You have not specified the discovery uri, -e DISCOVERY=[BACKEND]"
  exit 1
fi

/bin/embassy -discovery ${DISCOVERY} -interface ${INTERFACE} -alsologtostderr=true -v ${VERBOSE}
