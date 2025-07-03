ARG DOCKER_USER=gbuchanan/hpc-demo
ARG HPCTS_VERSION=latest

FROM ${DOCKER_USER}:base-v2-${HPCTS_VERSION}

# Install SLURM dependencies
RUN dnf install -y \
    mariadb-devel \
    pam-devel \
    perl-ExtUtils-MakeMaker \
    rpm-build \
    hwloc-devel \
    lua-devel \
    lz4-devel \
    freeipmi-devel \
    hdf5-devel \
    man2html \
    && dnf clean all

# Set SLURM version
ARG SLURM_VERSION=24.05.7

# Download and build SLURM
WORKDIR /tmp
RUN wget https://download.schedmd.com/slurm/slurm-${SLURM_VERSION}.tar.bz2 && \
    tar -xjf slurm-${SLURM_VERSION}.tar.bz2

WORKDIR /tmp/slurm-${SLURM_VERSION}
RUN ./configure \
    --prefix=/usr \
    --sysconfdir=/etc/slurm \
    --localstatedir=/var \
    --with-munge \
    --with-pam \
    --with-hwloc \
    --with-lua \
    --with-hdf5 \
    --enable-pam \
    && make -j$(nproc) \
    && make install

# Create SLURM users and directories
RUN groupadd -r slurm && \
    useradd -r -g slurm -d /var/lib/slurm -s /sbin/nologin slurm && \
    mkdir -p /var/spool/slurmd /var/log/slurm /var/lib/slurm /etc/slurm && \
    chown slurm:slurm /var/spool/slurmd /var/log/slurm /var/lib/slurm

# Install Python packages needed for SLURM
RUN pip3 install PyMySQL

# Copy SLURM configuration files
COPY slurm.conf /etc/slurm/slurm.conf
COPY slurmdbd.conf /etc/slurm/slurmdbd.conf
COPY cgroup.conf /etc/slurm/cgroup.conf

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Clean up
WORKDIR /
RUN rm -rf /tmp/slurm-*

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
