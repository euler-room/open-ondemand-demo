FROM rockylinux:9

# Install OnDemand 4.0 repository first to ensure compatibility
RUN dnf install -y https://yum.osc.edu/ondemand/4.0/ondemand-release-web-4.0-1.el9.noarch.rpm

# Enable required repositories
RUN dnf install -y epel-release dnf-plugins-core && \
    dnf config-manager --set-enabled crb

# Install Node.js 20 from NodeSource
RUN curl -fsSL https://rpm.nodesource.com/setup_20.x | bash - && \
    dnf install -y nodejs

# Install base system packages optimized for OnDemand 4.0
RUN dnf install -y --allowerasing \
    git wget curl vim nano \
    openssl openssl-devel \
    gcc gcc-c++ make cmake \
    python3 python3-pip python3-devel \
    httpd httpd-devel mod_ssl \
    munge munge-devel \
    sssd sssd-client \
    sudo which hostname \
    rsyslog systemd \
    && dnf clean all

# Install Ruby 3.3+ from OnDemand repo (ensures compatibility)
RUN dnf module enable -y ruby:3.3 && \
    dnf install -y ruby ruby-devel ruby-libs \
    rubygem-bundler rubygem-rake

# Install additional development tools
RUN dnf groupinstall -y "Development Tools" && \
    dnf install -y \
    autoconf automake libtool \
    libcurl-devel sqlite-devel \
    zlib-devel readline-devel \
    libyaml-devel libffi-devel \
    && dnf clean all

# Set up basic directory structure
RUN mkdir -p /etc/munge /var/log /var/run && \
    chmod 700 /etc/munge

# Ensure munge user and directories exist
RUN mkdir -p /var/lib/munge /var/log/munge /var/run/munge && \
    chown munge:munge /var/lib/munge /var/log/munge /var/run/munge

# Set up SSSD for LDAP integration
COPY sssd.conf /etc/sssd/sssd.conf
RUN chmod 600 /etc/sssd/sssd.conf

ENTRYPOINT ["/bin/bash"]
