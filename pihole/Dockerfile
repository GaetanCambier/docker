LABEL	maintainer="Gaetan Cambier Gaetan@Cambier.org"

ENV PATH /opt/pihole:${PATH}

COPY install.sh /usr/local/bin/docker-install.sh
ENV setupVars /etc/pihole/setupVars.conf
ENV PIHOLE_INSTALL /tmp/ph_install.sh

RUN	apk add \
	bash bc bind-tools \
	ca-certificates curl \
	dnsmasq \
	git \
	libcap libxml2 \
	nginx \
	perl php7-fpm php7-json php7-openssl php7-zip php7-sockets \
	sudo \
	wget && \
	docker-install.sh

# Things installer did and fix alpine+nginx differences
ENV	WEBLOGDIR /var/log/nginx
ENV	PHP_CONFIG '/etc/php7/php-fpm.conf'
RUN	\
#	mkdir -p /etc/pihole/ && \
   	mkdir -p /var/www/html/pihole && \
	mkdir -p /var/www/html/admin/ && \
	chown nginx:nginx /var/www/html && \
	chmod 775 /var/www/html && \
#	touch ${WEBLOGDIR}/access.log ${WEBLOGDIR}/error.log && \
#	chown -R nginx:nginx ${WEBLOGDIR} && \
	sed -i 's|^user\s*=.*$|user = nginx|' $PHP_CONFIG && \
	sed -i '/^;pid/ s|^;||' $PHP_CONFIG && \
#	touch /var/log/pihole.log && \
#	chmod 644 /var/log/pihole.log && \
#	chown dnsmasq:root /var/log/pihole.log && \
	sed -i "s/@INT@/eth0/" /etc/dnsmasq.d/01-pihole.conf && \
	setcap CAP_NET_BIND_SERVICE=+eip `which dnsmasq` && \
	cp -f /usr/bin/list.sh /opt/pihole/list.sh && \

# php config start passes special ENVs into
ENV	PHP_ENV_CONFIG '/etc/php7/fpm.d/envs.conf'
ENV	PHP_ERROR_LOG '/var/log/nginx/error.log'
COPY	./start.sh / \
	./bash_functions.sh /

# IPv6 disable flag for networks/devices that do not support it
ENV IPv6 True

EXPOSE 53/tcp 53/udp 80

ENTRYPOINT [ "/entrypoint.sh" ]
