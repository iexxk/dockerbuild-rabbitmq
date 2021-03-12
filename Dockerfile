FROM rabbitmq:3.7-alpine

ENV NETSIZE 2mbit
ENV NETDELAY 50ms
ENV NETBURST 100000 

COPY docker-entrypoint.sh /usr/local/bin/

RUN rabbitmq-plugins enable --offline rabbitmq_management rabbitmq_stomp rabbitmq_web_stomp

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
	apk add --no-cache python iproute2; \
	ln -s usr/local/bin/docker-entrypoint.sh /entrypoint.sh \
	rabbitmqadmin --version
	

EXPOSE 15671 15672 15674

ENTRYPOINT ["docker-entrypoint.sh"]
