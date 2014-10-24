#
#   Author: Rohith
#   Date: 2014-10-17 00:40:22 +0100 (Fri, 17 Oct 2014)
#
#  vim:ts=2:sw=2:et
#
FROM gambol99/ubuntu-base:latest
MAINTAINER <gambol99@gmail.com>
RUN wget https://github.com/hashicorp/consul-template/releases/download/v0.1.0/consul-template_0.1.0_linux_amd64.tar.gz -O /tmp/consul-template_0.1.0_linux_amd64.tar.gz && \
  tar zxvf /tmp/consul-template_0.1.0_linux_amd64.tar.gz -C /tmp && \
  mv /tmp/consul-template_0.1.0_linux_amd64/consul-template /usr/bin/consul-template && \
  rm -rf /tmp/consul-template_0.1.0_linux_amd64 /tmp/consul-template_0.1.0_linux_amd64.tar.gz && \
  chmod +x /usr/bin/consul-template
RUN mkdir -p \
  /dockerbase \
  /etc/consul/conf.d \
  /etc/consul/templates \
  /etc/supervisor/conf.d
RUN rm -f /etc/cron.daily/standard
ADD runner.sh /runner.sh
ADD cleanup.sh dockerbase/cleanup.sh
ADD config/supervisord.conf /etc/supervisor/supervisord.conf
RUN bash /dockerbase/cleanup.sh
RUN chmod ug+x /runner.sh
ENTRYPOINT [ "/runner.sh"]
