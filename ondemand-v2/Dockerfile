ARG DOCKER_USER=gbuchanan/hpc-demo
ARG HPCTS_VERSION=2025.07

FROM ${DOCKER_USER}:slurm-v2-${HPCTS_VERSION}

# Follow the official OnDemand installation documentation
# Install OnDemand 4.0 release repository
RUN dnf install -y https://yum.osc.edu/ondemand/4.0/ondemand-release-web-4.0-1.el9.noarch.rpm

# Install OnDemand with all required dependencies according to documentation
RUN dnf module reset nodejs -y && \
    dnf module enable nodejs:20 -y && \
    dnf install -y --nogpgcheck ondemand ondemand-dex httpd mod_ssl python3-websockify && \
    dnf clean all

# Install additional packages for HPC demo environment
RUN dnf install -y netcat lsof sudo file rsync nmap-ncat \
    openssh-server openssh-clients \
    && dnf clean all

# Set up OnDemand directories according to documentation
RUN mkdir -p /var/lib/ondemand-nginx/config/puns && \
    touch /var/lib/ondemand-nginx/config/puns/.seq && \
    mkdir -p /var/log/ondemand-nginx && \
    mkdir -p /var/run/ondemand-nginx && \
    mkdir -p /var/tmp/ondemand-nginx && \
    mkdir -p /etc/ood/config/clusters.d && \
    mkdir -p /etc/ood/config/apps && \
    mkdir -p /var/run/passenger-instreg

# Copy OnDemand configuration files
COPY cluster-config.yml /etc/ood/config/clusters.d/hpc.yml
COPY ood_portal.yml /etc/ood/config/ood_portal.yml
COPY nginx_stage.yml /etc/ood/config/nginx_stage.yml

# Copy custom apps and configurations
COPY apps/ /var/www/ood/apps/sys/
COPY config/ /etc/ood/config/

# Set correct permissions for OnDemand apps
RUN chmod 755 /var/www/ood/apps/sys/projects

# Set up SSL certificates for HTTPS
RUN mkdir -p /etc/pki/tls/certs /etc/pki/tls/private && \
    openssl req -new -x509 -nodes -out /etc/pki/tls/certs/localhost.crt \
    -keyout /etc/pki/tls/private/localhost.key -days 365 \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"

# Generate OnDemand portal configuration following documentation
RUN /opt/ood/ood-portal-generator/sbin/update_ood_portal

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/ondemand-entrypoint.sh
RUN chmod +x /usr/local/bin/ondemand-entrypoint.sh

EXPOSE 3443 5554

ENTRYPOINT ["/usr/local/bin/ondemand-entrypoint.sh"]
