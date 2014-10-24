#
#   Author: Rohith (gambol99@gmail.com)
#   Date: 2014-10-24 13:26:09 +0100 (Fri, 24 Oct 2014)
#
#  vim:ts=2:sw=2:et
#

# Environment Variables
#
# REDIS_MASTER=[CONSUL_SERVICE]
#
#

FROM gambol99/service:latest
MAINTAINER <gambol99@gmail.com>
RUN \
  cd /tmp && \
  wget http://download.redis.io/redis-stable.tar.gz && \
  tar xvzf redis-stable.tar.gz && \
  cd redis-stable && \
  make && \
  make install && \
  cp -f src/redis-sentinel /usr/local/bin && \
  mkdir -p /etc/redis && \
  cp -f *.conf /etc/redis && \
  rm -rf /tmp/redis-stable* && \
  sed -i 's/^\(bind .*\)$/# \1/' /etc/redis/redis.conf && \
  sed -i 's/^\(daemonize .*\)$/# \1/' /etc/redis/redis.conf && \
  sed -i 's/^\(dir .*\)$/# \1\ndir \/data/' /etc/redis/redis.conf && \
  sed -i 's/^\(logfile .*\)$/# \1/' /etc/redis/redis.conf

VOLUME ["/data"]
WORKDIR /data
ADD consul/templates/redis.conf.tpl /etc/consul/templates/redis.conf.tpl
ENV CONSUL_ONETIME_REDIS redis.conf.tpl:/etc/redis/redis.conf:/usr/bin/true
ENV CONSUL_SERVICE_REDIS redis.conf.tpl:/etc/redis/redis.conf:/usr/bin/supervisorctl reload runner
CMD [ "/usr/local/bin/redis-server", "/etc/redis/redis.conf" ]
EXPOSE 6379
