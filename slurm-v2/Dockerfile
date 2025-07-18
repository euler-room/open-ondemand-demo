ARG DOCKER_USER=gbuchanan/hpc-demo
ARG HPCTS_VERSION=2025.07

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
    munge \
    munge-devel \
    && dnf clean all

# Install websockify via pip
RUN pip3 install websockify

# Install Ruby 3.3+ (needed for OnDemand)
RUN dnf module enable -y ruby:3.3 && \
    dnf install -y ruby ruby-devel ruby-libs \
    rubygem-bundler rubygem-rake

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
RUN dnf install -y python3-pip && \
    pip3 install PyMySQL

# Copy SLURM configuration files
COPY slurm.conf /etc/slurm/slurm.conf
COPY slurmdbd.conf /etc/slurm/slurmdbd.conf
COPY cgroup.conf /etc/slurm/cgroup.conf

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY init-accounts.sh /usr/local/bin/init-accounts.sh
RUN chmod +x /usr/local/bin/init-accounts.sh

# Clean up
WORKDIR /
RUN rm -rf /tmp/slurm-*

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Install Jupyter for OnDemand integration
RUN python3 -m venv /usr/local/jupyter/4.3.5 && \
    source /usr/local/jupyter/4.3.5/bin/activate && \
    pip install --upgrade pip && \
    pip install jupyterlab jupyter notebook ipywidgets && \
    deactivate

# Create wrapper script for Jupyter
RUN echo '#!/bin/bash\nsource /usr/local/jupyter/4.3.5/bin/activate\nexec "$@"' > /usr/local/jupyter/4.3.5/bin/activate-wrapper && \
    chmod +x /usr/local/jupyter/4.3.5/bin/activate-wrapper

# Install VNC and desktop packages
RUN dnf install -y epel-release && \
    dnf config-manager --set-enabled crb && \
    dnf install -y \
    tigervnc-server \
    xorg-x11-server-utils \
    xorg-x11-fonts-Type1 \
    xorg-x11-xinit \
    xterm \
    firefox \
    gnome-terminal \
    mate-desktop \
    mate-session-manager \
    mate-panel \
    mate-terminal \
    mate-settings-daemon \
    mate-control-center \
    mate-polkit \
    marco \
    caja \
    mate-notification-daemon \
    mate-screensaver \
    mate-menus \
    mate-backgrounds \
    mate-themes \
    && dnf clean all

# Install websockify via pip
RUN pip3 install websockify

# Setup VNC xstartup template  
RUN mkdir -p /etc/skel/.vnc && \
    echo '#!/bin/bash' > /etc/skel/.vnc/xstartup && \
    echo 'unset SESSION_MANAGER' >> /etc/skel/.vnc/xstartup && \
    echo 'unset DBUS_SESSION_BUS_ADDRESS' >> /etc/skel/.vnc/xstartup && \
    echo 'xsetroot -solid "#2e3440"' >> /etc/skel/.vnc/xstartup && \
    echo 'export XDG_CURRENT_DESKTOP=MATE' >> /etc/skel/.vnc/xstartup && \
    echo 'export DESKTOP_SESSION=mate' >> /etc/skel/.vnc/xstartup && \
    echo 'exec mate-session' >> /etc/skel/.vnc/xstartup && \
    chmod 755 /etc/skel/.vnc/xstartup

# Add TurboVNC repository
RUN curl -o /etc/yum.repos.d/turbovnc.repo https://raw.githubusercontent.com/TurboVNC/repo/main/TurboVNC.repo

# Install TurboVNC
RUN dnf install -y turbovnc && dnf clean all

# Install websockify via pip
RUN pip3 install websockify

# Add TurboVNC to PATH for all users
RUN echo 'export PATH="/opt/TurboVNC/bin:$PATH"' >> /etc/profile.d/turbovnc.sh
