#!/bin/bash
#
#   Author: Rohith (gambol99@gmail.com)
#   Date: 2014-10-24 12:59:56 +0100 (Fri, 24 Oct 2014)
#
#  vim:ts=2:sw=2:et
#

CONSUL_BIN="/usr/bin/consul-template"
CONSUL_HOST=${CONSUL_HOST:-consul.consul}
CONSUL_BASE=${CONSUL_CONFD:-/etc/consul}
CONSUL_CONFD="${CONSUL_BASE}/conf.d"
CONSUL_CONFIG=${CONSUL_CONFIG:-""}
CONSUL_TEMPLATES=${CONSUL_TEMPLATES:-""}

CONSUL_SERVICE=${CONSUL_SERVICE_PREFIX:-"SERVICE"}
CONSUL_ONETIME=${CONSUL_ONETIME_PREFIX:-"ONETIME"}
CONSUL_SERVICES="CONSUL_(${CONSUL_SERVICE}|${CONSUL_ONETIME})_"

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
command=${COMMAND_ARGS}
stdout_logfile=/var/log/supervisor/%(program_name)s.log
stderr_logfile=/var/log/supervisor/%(program_name)s_error.log
EOF
  annonce "Runner Configuration"
  cat /etc/supervisor/conf.d/runner.conf
}

consul_onetime() {
  [[ "$@" =~ ^CONSUL_${CONSUL_ONETIME}_.*$ ]] && return 0 || return 1
}

consul_service() {
  [[ "$@" =~ ^CONSUL_${CONSUL_SERVICE}_.*$ ]] && return 0 || return 1
}
#
# CONSUL_SERVICE_<NAME>   : these are added the consul daemon service
# CONSUL_ONETIME_<NAME>   : these are run just once; and are normally used to grab the initial configuration
#
consul_services() {
  annonce "Setting up the Consul Service"
  # step: generate a list of templates to use
  while IFS='=' read NAME CONFIG; do
    # step: verify the format
    if [[ "$CONFIG" =~ ^(.*):(.*):(.*)$ ]]; then
      # step: check the template exists
      template_file="/etc/consul/templates/${BASH_REMATCH[1]}"
      destination=${BASH_REMATCH[2]}
      reload=${BASH_REMATCH[3]}
      [ -f "$template_file" ] || {
        annonce "Error; the template file: $template_file does not exist";
        continue;
      }
      # step: check if it's a onetime
      if consul_onetime "$NAME"; then
        template="${template_file}:${destination}:${reload}"
        annonce "Consul Onetime Configuration: $template"
        if ! $CONSUL_BIN -consul $CONSUL_HOST -once -template $template; then
          annonce "Failed to perform onetime configuration: $template, exit code: $?"
        else
          annonce "Successfully ran onetime configuration: $template"
        fi
      else
        template="\"${template_file}:${destination}:${reload}\""
        annonce "Adding the consul service template: $template"
        CONSUL_TEMPLATES=" $CONSUL_TEMPLATES -template $template"
      fi
    else
      annonce "Error; the template: $CONFIG is invalid, should be <template>:<dest>:<reload>"
    fi
  done < <(set | egrep "^${CONSUL_SERVICES}.*=.*$" | sed "s/'//g")
}

consul_setup() {
  # step: read in the templates
  consul_services
  # step: add the supervisord config for consul if were not empty
  if [ -n "$CONSUL_TEMPLATES" ]; then
cat <<EOF > /etc/supervisor/conf.d/consul.conf
[program:consul]
user=root
directory=${CONSUL_BASE}
command=${CONSUL_BIN} -consul ${CONSUL_HOST} ${CONSUL_TEMPLATES}
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

if ! [[ "${COMMAND_ARGS}" =~ ^/(usr/|)bin/(bash|sh|zsh).*$ ]]; then
  annonce "Starting the supervisord daemon service"
  /usr/bin/supervisord -c /etc/supervisor/supervisord.conf -n
else
  annonce "Switching into a shell"
  # step: it's a shell
  exec "$@"
fi
