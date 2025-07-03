ARG DOCKER_USER=gbuchanan/hpc-demo
ARG HPCTS_VERSION=latest

FROM ${DOCKER_USER}:slurm-v2-${HPCTS_VERSION}

# Install OnDemand 4.0+ and dependencies
RUN dnf install -y \
    ondemand \
    ondemand-dex \
    nginx \
    && dnf clean all

# Verify Ruby version is compatible with OnDemand 4.0
RUN ruby --version && gem --version

# Install additional Ruby gems needed
RUN gem install dotenv bcrypt

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
