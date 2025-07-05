ARG DOCKER_USER=gbuchanan/hpc-demo
ARG HPCTS_VERSION=2025.07

FROM ${DOCKER_USER}:slurm-v2-${HPCTS_VERSION}

# Install OnDemand build dependencies and runtime packages
RUN dnf install -y \
    git \
    nginx \
    redis \
    sqlite \
    sqlite-devel \
    openssl-devel \
    libffi-devel \
    libyaml-devel \
    zlib-devel \
    readline-devel \
    && dnf clean all

# Verify Ruby and Node.js versions
RUN ruby --version && gem --version && node --version && npm --version

# Install required Ruby gems for OnDemand
RUN gem install bundler rake

# Install additional Ruby gems needed for OnDemand
RUN gem install rails sinatra passenger

# Create minimal OnDemand installation structure 
RUN mkdir -p /opt/ood/apps/sys \
    /opt/ood/apps/dev \
    /opt/ood/nginx_stage/bin \
    /opt/ood/ood-portal-generator/sbin

# Create a simple nginx_stage wrapper
RUN echo '#!/bin/bash' > /opt/ood/nginx_stage/bin/nginx_stage && \
    echo 'exec nginx "$@"' >> /opt/ood/nginx_stage/bin/nginx_stage && \
    chmod +x /opt/ood/nginx_stage/bin/nginx_stage

# Create a simple ood-portal-generator
RUN echo '#!/bin/bash' > /opt/ood/ood-portal-generator/sbin/update_ood_portal && \
    echo 'echo "OnDemand portal configuration updated"' >> /opt/ood/ood-portal-generator/sbin/update_ood_portal && \
    chmod +x /opt/ood/ood-portal-generator/sbin/update_ood_portal

# Create OnDemand directory structure
RUN mkdir -p /opt/ood/nginx_stage/sockets \
    /opt/ood/nginx_stage/tmp \
    /var/www/ood/apps/sys \
    /var/www/ood/apps/usr \
    /var/www/ood/apps/dev

# Create OnDemand nginx user
RUN useradd -r -s /sbin/nologin -d /var/lib/ondemand-nginx -c "OnDemand Nginx User" ondemand-nginx

# Set up OnDemand directories
RUN mkdir -p \
    /var/lib/ondemand-nginx/config/puns \
    /var/lib/ondemand-nginx/config/apps/sys \
    /var/lib/ondemand-nginx/config/apps/dev \
    /var/lib/ondemand-nginx/config/apps/usr \
    /var/log/ondemand-nginx \
    /var/run/ondemand-nginx \
    /var/tmp/ondemand-nginx \
    /etc/ood/config/clusters.d \
    /etc/ood/config/apps \
    && touch /var/lib/ondemand-nginx/config/puns/.seq

# Copy OnDemand configuration files
COPY ood_portal.yml /etc/ood/config/ood_portal.yml
COPY cluster-config.yml /etc/ood/config/clusters.d/hpc.yml
COPY nginx_stage.yml /etc/ood/config/nginx_stage.yml

# Copy custom apps and configurations
COPY apps/ /var/www/ood/apps/sys/
COPY config/ /etc/ood/config/

# Set up SSL certificates
RUN mkdir -p /etc/pki/tls/certs /etc/pki/tls/private && \
    openssl req -new -x509 -nodes -out /etc/pki/tls/certs/localhost.crt \
    -keyout /etc/pki/tls/private/localhost.key -days 365 \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"

# Generate OnDemand portal configuration
RUN /opt/ood/ood-portal-generator/sbin/update_ood_portal

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/ondemand-entrypoint.sh
RUN chmod +x /usr/local/bin/ondemand-entrypoint.sh

EXPOSE 3443 5554

ENTRYPOINT ["/usr/local/bin/ondemand-entrypoint.sh"]
