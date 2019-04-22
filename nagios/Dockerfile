FROM	jasonrivers/nagios:latest
LABEL	maintainer="Gaetan Cambier Gaetan@Cambier.org"

RUN	apt-get update && apt-get install -y				\
	ca-certificates \
	msmtp \
	libfreeradius-client2 \
&&	apt-get clean

