FROM httpd:2.4
MAINTAINER "cytopia" <cytopia@everythingcli.org>

# Environment Variables
ENV LOGDIR=/var/log/apache2


# Install PHP 1.0
RUN set -x \
	&& DEBIAN_FRONTEND=noninteractive apt-get update -qq \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -qq -y --no-install-recommends --no-install-suggests \
		curl \
		ca-certificates \
		gcc \
		make \
	&& curl https://museum.php.net/php1/php-108.tar.gz -o /usr/src/php-108.tar.gz \
	&& tar xvfz /usr/src/php-108.tar.gz -C /usr/src/ \
	&& cd /usr/src/php \
	\
	&& rm config.h \
	&& touch config.h \
	&& echo "#define ROOTDIR \"/\"" >> config.h \
	&& echo "#define LOGDIR \"${LOGDIR}/\"" >> config.h \
	&& echo "#define ACCDIR \"${LOGDIR}/\"" >> config.h \
	&& echo "#define NOACCESS \"NoAccess.html\"" >> config.h \
	&& mkdir -p ${LOGDIR} \
	&& chmod 0777 ${LOGDIR} \
	\
	&& make \
	&& cp php*.cgi /usr/local/bin/ \
	&& chmod +x /usr/local/bin/php*.cgi \
	&& cd / \
	&& rm -rf /usr/src/php \
	&& rm -rf /usr/src/php-108.tar.gz \
	&& DEBIAN_FRONTEND=noninteractive apt-get purge -qq -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
		curl \
		gcc \
		make \
	&& rm -rf /var/lib/apt/lists/*


# Configure Apache
RUN set -x \
	&& echo "Include conf/extra/php-cgi.conf" >> /usr/local/apache2/conf/httpd.conf

COPY data/php-cgi.conf /usr/local/apache2/conf/extra/php-cgi.conf


# Runtime Setup
EXPOSE 80
CMD ["httpd-foreground"]
