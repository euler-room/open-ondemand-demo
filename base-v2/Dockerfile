FROM rockylinux:9

# Install OnDemand 4.0 repository first to ensure compatibility
RUN dnf install -y https://yum.osc.edu/ondemand/4.0/ondemand-release-web-4.0-1.el9.noarch.rpm

# Enable required repositories
RUN dnf install -y epel-release dnf-plugins-core && \
    dnf config-manager --set-enabled crb

# Install base system packages (without Node.js and Ruby - those will be added in specific images)
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
    openssh-server openssh-clients \
    && dnf clean all

# Install gosu from GitHub releases
RUN curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.17/gosu-$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/')" \
    && chmod +x /usr/local/bin/gosu

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
