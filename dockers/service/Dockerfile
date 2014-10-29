#
#   Author: Rohith
#   Date: 2014-10-17 00:40:22 +0100 (Fri, 17 Oct 2014)
#
#  vim:ts=2:sw=2:et
#
FROM gambol99/ubuntu-base:latest
MAINTAINER <gambol99@gmail.com>

RUN sudo wget http://github.com/kelseyhightower/confd/releases/download/v0.6.3/confd-0.6.3-linux-amd64 -O /usr/bin/confd && chmod +x /usr/bin/confd
RUN mkdir -p \
  /dockerbase \
  /etc/confd/onetime/conf.d \
  /etc/confd/onetime/templates \
  /etc/confd/conf.d \
  /etc/confd/templates \
  /etc/supervisor/conf.d
RUN rm -f /etc/cron.daily/standard
ADD runner.sh /runner.sh
ADD cleanup.sh dockerbase/cleanup.sh
ADD config/supervisord.conf /etc/supervisor/supervisord.conf
RUN bash /dockerbase/cleanup.sh
RUN chmod ug+x /runner.sh
ENTRYPOINT [ "/runner.sh"]
