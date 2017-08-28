FROM	jasonrivers/nagios:latest
LABEL	maintainer="Gaetan Cambier Gaetan@Cambier.org"

RUN	apt-get update && apt-get install -y				\
	sendemail \
	libio-socket-ssl-perl \
	libnet-ssleay-perl \
	perl \
	'perl(Net::SSLeay)' \
	'perl(IO::Socket::SSL)' \
&&	apt-get clean

