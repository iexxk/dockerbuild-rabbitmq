#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM rabbitmq:3.8-alpine

ENV NETSIZE 2mbit
ENV NETDELAY 50ms
ENV NETBURST 100000

COPY docker-entrypoint-extend.sh /usr/local/bin/

RUN rabbitmq-plugins enable --offline rabbitmq_management rabbitmq_stomp rabbitmq_web_stomp

# make sure the metrics collector is re-enabled (disabled in the base image for Prometheus-style metrics by default)
RUN rm -f /etc/rabbitmq/conf.d/management_agent.disable_metrics_collector.conf

# extract "rabbitmqadmin" from inside the "rabbitmq_management-X.Y.Z.ez" plugin zipfile
# see https://github.com/docker-library/rabbitmq/issues/207
RUN set -eux; \
	erl -noinput -eval ' \
		{ ok, AdminBin } = zip:foldl(fun(FileInArchive, GetInfo, GetBin, Acc) -> \
			case Acc of \
				"" -> \
					case lists:suffix("/rabbitmqadmin", FileInArchive) of \
						true -> GetBin(); \
						false -> Acc \
					end; \
				_ -> Acc \
			end \
		end, "", init:get_plain_arguments()), \
		io:format("~s", [ AdminBin ]), \
		init:stop(). \
	' -- /plugins/rabbitmq_management-*.ez > /usr/local/bin/rabbitmqadmin; \
	[ -s /usr/local/bin/rabbitmqadmin ]; \
	chmod +x /usr/local/bin/rabbitmqadmin; \
	chmod +x /usr/local/bin/docker-entrypoint-extend.sh; \
	apk add --no-cache python3 iproute2; \
	rabbitmqadmin --version

EXPOSE 15671 15672 15674

ENTRYPOINT ["/usr/local/bin/docker-entrypoint-extend.sh"]
