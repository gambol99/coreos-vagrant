#!/bin/bash
#
#   Author: Rohith (gambol99@gmail.com)
#   Date: 2014-10-24 12:59:56 +0100 (Fri, 24 Oct 2014)
#
#  vim:ts=2:sw=2:et
#

CONFD_BIN="/usr/bin/confd"
CONFD_HOST=${CONFD_HOST:-"127.0.0.1:4001"}
CONFD_BASE=${CONFD_CONFD:-/etc/confd}
CONFD_BASE_ONETIME=${CONFD_BASE}/onetime
CONFD_CONFD="${CONFD_BASE}/conf.d"
SUPERVISORD=/usr/bin/supervisord

annonce() {
  echo "** $@"
  echo
}

runner_service() {
  annonce "Adding the runner service to supervisord"
  cat <<EOF > /etc/supervisor/conf.d/runner.conf
[program:runner]
user=root
group=root
directory=/
command=${COMMAND_ARGS}
stdout_logfile=/var/log/supervisor/%(program_name)s.log
stderr_logfile=/var/log/supervisor/%(program_name)s_error.log
EOF
  annonce "Runner Configuration"
  cat /etc/supervisor/conf.d/runner.conf
}

confd_service() {
  cat <<EOF > /etc/supervisor/conf.d/confd.conf
[program:confd]
user=root
directory=${CONFD_BASE}
command=${CONFD_BIN} -confdir ${CONFD_BASE} -node ${CONFD_HOST} -verbose
stdout_logfile=/var/log/supervisor/%(program_name)s.log
stderr_logfile=/var/log/supervisor/%(program_name)s_error.log
EOF
}

confd_setup() {
  # step: perform any onetime confd runs
  confd_onetime
  # step: add the supervisord config for confd if were not empty
  CONFD_TEMPLATES=$(find /etc/confd/conf.d -type f | wc -l)
  if [ ! "$CONFD_TEMPLATES" == "0" ]; then
    annonce "Adding the Confd Service to supervisord"
    confd_service
  else
    annonce "We have no CONFD templates to add"
  fi
}

confd_onetime() {
  annonce "Performing onetime confd runs"
  ${CONFD_BIN} -confdir ${CONFD_BASE_ONETIME} -node ${CONFD_HOST} -verbose
  [ $? -ne 0 ] || annonce "We encountered an error performing the onetime run"
}

services_setup() {
  # step: setup the confd services
  confd_setup
  # step: setup the supervisord setup
  runner_service "${COMMAND_ARGS}"
}

# step: grab the command line arguments
COMMAND_ARGS="$@"
annonce "Runner arguments: ${COMMAND_ARGS}"
# step: setup supervisord
services_setup

if ! [[ "${COMMAND_ARGS}" =~ ^/(usr/|)bin/(bash|sh|zsh).*$ ]]; then
  annonce "Starting the supervisord daemon service"
  $SUPERVISORD -c /etc/supervisor/supervisord.conf -n
else
  annonce "Switching into a shell"
  # step: it's a shell
  exec "$@"
fi
