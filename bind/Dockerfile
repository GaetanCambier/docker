LABEL	maintainer="Gaetan Cambier Gaetan@Cambier.org"

EXPOSE  53/tcp 53/udp

ENV     BIND_USER=named \
	DATA_DIR=/data

RUN	apk add --no-cache bash bind tzdata

COPY	entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
