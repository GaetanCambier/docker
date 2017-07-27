LABEL	maintainer="Gaetan Cambier Gaetan@Cambier.org"

EXPOSE  53/tcp 53/udp

ENV     BIND_USER=named \
	DATA_DIR=/data

RUN	apk add --no-cache bind && \
	mkdir -m 0755 -p /var/run/named

COPY	entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
