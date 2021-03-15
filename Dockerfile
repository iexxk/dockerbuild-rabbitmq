FROM exxk/rabbitmq:latest

ENV NETSIZE 2mbit
ENV NETDELAY 50ms
ENV NETBURST 100000 

COPY docker-entrypoint-extend.sh /usr/local/bin/

RUN  apk add --no-cache iproute2; \
	chmod +x /usr/local/bin/docker-entrypoint-extend.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint-extend.sh"]
