LABEL	maintainer="Gaetan Cambier Gaetan@Cambier.org"

EXPOSE  53/tcp 53/udp

ENV     BIND_USER=named \
	DATA_DIR=/data

RUN	apk add --no-cache --upgrade bash tzdata bind

COPY	entrypoint.sh /

HEALTHCHECK CMD nslookup ::1 ::1 || exit 1

ENTRYPOINT ["/entrypoint.sh"]
