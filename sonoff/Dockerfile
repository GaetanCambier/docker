LABEL	maintainer="Gaetan Cambier Gaetan@Cambier.org"

RUN	apk add \
	bash bc bind-tools \
	ca-certificates curl \
	sudo \
	npm \
	wget && \
	docker-install.sh

ENV HTTP_PORT=8080
ENV HTTPS_PORT=8443
ENV WEBSOCKET_PORT=9443

WORKDIR simple-sonoff-server
ADD ./ ./

RUN npm install 

EXPOSE 8080/tcp 8443/tcp 9443/tcp

ENTRYPOINT [ "nodejs" "sonoff.server.js" ]
