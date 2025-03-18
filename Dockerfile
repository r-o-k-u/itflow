FROM ubuntu:22.04

LABEL dockerfile.version="v2.1" dockerfile.release-date="2024-03-18"

# Environment variables
ENV TZ=Africa/Nairobi \
    ITFLOW_NAME=ITFlow \
    ITFLOW_URL=localhost \
    ITFLOW_PORT=8080 \
    ITFLOW_SSL_PORT=8443 \
    ITFLOW_REPO=github.com/r-o-k-u/itflow \
    ITFLOW_REPO_BRANCH=master \
    ITFLOW_LOG_LEVEL=warn \
    ITFLOW_DB_HOST=null \
    ITFLOW_DB_PASS=null

# Set timezone
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y software-properties-common openssl && \
    add-apt-repository ppa:ondrej/php -y && \
    apt-get update && \
    apt-get install -y \
        git \
        apache2 \
        php8.0 \
        php8.0-intl \
        php8.0-mysqli \
        php8.0-curl \
        php8.0-imap \
        php8.0-mailparse \
        libapache2-mod-php8.0 \
        libapache2-mod-md \
        vim \
        cron \
        dnsutils \
        iputils-ping \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Generate self-signed SSL certificate
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/itflow-selfsigned.key \
    -out /etc/ssl/certs/itflow-selfsigned.crt \
    -subj "/C=KE/ST=Nairobi/L=Nairobi/O=ITFlow/CN=${ITFLOW_URL}"

# Configure Apache
RUN a2enmod php8.0 md rewrite ssl && \
    sed -i "s/Listen 80/Listen ${ITFLOW_PORT}/g" /etc/apache2/ports.conf && \
    sed -i "s/Listen 443/Listen ${ITFLOW_SSL_PORT}/g" /etc/apache2/ports.conf && \
    sed -i \
        -e "s/:80/:${ITFLOW_PORT}/g" \
        -e "s/:443/:${ITFLOW_SSL_PORT}/g" \
        /etc/apache2/sites-available/*.conf && \
    sed -i \
        -e "s|SSLCertificateFile.*|SSLCertificateFile /etc/ssl/certs/itflow-selfsigned.crt|" \
        -e "s|SSLCertificateKeyFile.*|SSLCertificateKeyFile /etc/ssl/private/itflow-selfsigned.key|" \
        /etc/apache2/sites-available/default-ssl.conf && \
    a2ensite default-ssl

# PHP configuration
RUN echo "memory_limit = 512M" >> /etc/php/8.0/apache2/conf.d/00-custom.ini && \
    echo "upload_max_filesize = 40M" >> /etc/php/8.0/apache2/conf.d/00-custom.ini && \
    echo "post_max_size = 40M" >> /etc/php/8.0/apache2/conf.d/00-custom.ini

WORKDIR /var/www/html

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh

# Log configuration
RUN ln -sf /dev/stdout /var/log/apache2/access.log && \
    ln -sf /dev/stderr /var/log/apache2/error.log

EXPOSE $ITFLOW_PORT $ITFLOW_SSL_PORT
ENTRYPOINT ["entrypoint.sh"]
CMD ["apache2ctl", "-D", "FOREGROUND"]
