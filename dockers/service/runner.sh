#!/bin/bash
#
#   Author: Rohith (gambol99@gmail.com)
#   Date: 2014-10-24 12:59:56 +0100 (Fri, 24 Oct 2014)
#
#  vim:ts=2:sw=2:et
#

CONSUL_HOST=${CONSUL_HOST:-consul.consul}
CONSUL_BASE=${CONSUL_CONFD:-/etc/consul}
CONSUL_CONFD="${CONSUL_BASE}/conf.d"
CONSUL_TEMPLATES=${CONSUL_TEMPLATES:-""}

annonce() {
  echo "** $@"
  echo
}

supervisor_setup() {
  cat <<EOF > /etc/supervisor/conf.d/runner.conf
[program:runner]
user=root
group=root
directory=/
command="${COMMAND_ARGS}"
stdout_logfile=/var/log/supervisor/%(program_name)s.log
stderr_logfile=/var/log/supervisor/%(program_name)s_error.log
EOF
  annonce "Runner Configuration"
  cat /etc/supervisor/conf.d/runner.conf
}

consul_templates() {
  annonce "Setting up the Consul Templates"
  # step: generate a list of templates to use
  while read config_file; do
    CONSUL_TEMPLATES="$CONSUL_TEMPLATES -template $config_file "
  done < <(find ${CONSUL_CONFD} -name "*.conf" -type f)
}

consul_setup() {
  # step: read in the templates
  consul_templates

  # step: add the supervisord config for consul if were not empty
  if [ -n "$CONSUL_TEMPLATES" ]; then
cat <<EOF > /etc/supervisor/conf.d/consul.conf
[program:consul]
user=root
group=root
directory=${CONSUL_BASE}
command=/usr/bin/consul-template -consul ${CONSUL_HOST} ${CONSUL_TEMPLATES}
stdout_logfile=/var/log/supervisor/%(program_name)s.log
stderr_logfile=/var/log/supervisor/%(program_name)s_error.log
EOF
    annonce "Consul Template Configuration"
    cat /etc/supervisor/conf.d/consul.conf
  else
    annonce "We have no consul templates to add"
  fi
}

services_setup() {
  annonce "Setting up the background services"
  # step: generate the consul services
  consul_setup
  # step: generate the supervisord setup
  supervisor_setup "${COMMAND_ARGS}"
}

# step: grab the command line arguments
COMMAND_ARGS="$@"
annonce "Runner arguments: ${COMMAND_ARGS}"
# step: setup supervisord
services_setup

if ! [[ "${COMMAND_ARGS}" =~ ^/(usr/|)bin/(ba|)sh.*$ ]]; then
  annonce "Starting the supervisord daemon service"
  /usr/bin/supervisord -n
else
  # step: it's a shell
  exec "$@"
fi
