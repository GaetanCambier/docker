LABEL	maintainer="Gaetan Cambier Gaetan@Cambier.org"

EXPOSE  53/tcp 53/udp

ENV     BIND_USER=named \
	DATA_DIR=/data

RUN	apk add --no-cache --upgrade bash tzdata bind
RUN	apk add --no-cache --upgrade --no-scripts bind

COPY	entrypoint.sh /

HEALTHCHECK CMD nslookup 127.0.0.1 127.0.0.1 || exit 1

ENTRYPOINT ["/entrypoint.sh"]
