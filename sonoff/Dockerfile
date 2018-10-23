LABEL	maintainer="Gaetan Cambier Gaetan@Cambier.org"

RUN	apk add \
	npm


RUN 	npm install \
	express \
	nodejs-websocket

ENV	HTTP_PORT=8080 HTTPS_PORT=8443 WEBSOCKET_PORT=9443

WORKDIR simple-sonoff-server
ADD	./ ./

EXPOSE	8080/tcp 8443/tcp 9443/tcp

ENTRYPOINT [ "nodejs", "sonoff.server.js" ]
