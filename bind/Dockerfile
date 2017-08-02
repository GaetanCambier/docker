LABEL	maintainer="Gaetan Cambier Gaetan@Cambier.org"

EXPOSE  53/tcp 53/udp

ENV     BIND_USER=named \
	DATA_DIR=/data

RUN	apk add bind

COPY	entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
