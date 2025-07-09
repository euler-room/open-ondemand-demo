#!/bin/bash
set -e

if [ "$1" = "serve" ]
then
    echo "---> Starting OnDemand services..."
    
    # Wait for frontend ssh (optional, non-blocking)
    echo "-- Checking for frontend ssh connection..."
    timeout 10 bash -c 'until nc -z frontend 22 2>/dev/null; do sleep 1; done' || echo "-- Frontend not available, continuing without it"
    
    # Set up SSH host keys if needed
    if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
        echo "---> Generating SSH host keys..."
        ssh-keygen -A
    fi
    
    # Try to get frontend host key (non-critical)
    echo "---> Attempting to get frontend host key..."
    timeout 5 ssh-keyscan frontend 2>/dev/null >> /etc/ssh/ssh_known_hosts || echo "-- Could not get frontend host key, continuing"

    # Start SSSD (optional)
    echo "---> Starting SSSD..."
    rm -f /var/run/sssd.pid
    /usr/sbin/sssd -D 2>/dev/null || echo "-- SSSD failed to start, continuing"
    
    # Create local demo users for authentication (demo environment only)
    echo "---> Creating demo users..."
    for user in hpcadmin cgray sfoster csimmons astewart; do
        if ! id "$user" &>/dev/null; then
            useradd -m -s /bin/bash "$user"
            echo "$user:ilovelinux" | chpasswd
            # Set special password for cgray
            if [ "$user" = "cgray" ]; then
                echo "cgray:test123" | chpasswd
            fi
        fi
    done
    
    # Create htpasswd file for Apache authentication
    echo "---> Creating htpasswd file..."
    touch /etc/ood/htpasswd
    htpasswd -b /etc/ood/htpasswd hpcadmin ilovelinux
    htpasswd -b /etc/ood/htpasswd cgray test123
    htpasswd -b /etc/ood/htpasswd sfoster ilovelinux
    htpasswd -b /etc/ood/htpasswd csimmons ilovelinux
    htpasswd -b /etc/ood/htpasswd astewart ilovelinux
    chmod 644 /etc/ood/htpasswd

    # Set up MUNGE permissions and start
    echo "---> Setting up MUNGE..."
    mkdir -p /var/lib/munge /var/log/munge /var/run/munge /etc/munge
    chown -R munge:munge /var/lib/munge /var/log/munge /var/run/munge /etc/munge
    chmod 755 /var/lib/munge /var/run/munge
    chmod 700 /var/log/munge /etc/munge
    
    if [ ! -f /etc/munge/munge.key ]; then
        echo "---> Generating MUNGE key..."
        /usr/sbin/create-munge-key
        chown munge:munge /etc/munge/munge.key
        chmod 400 /etc/munge/munge.key
    fi
    
    echo "---> Starting MUNGE daemon..."
    /usr/sbin/munged &
    
    # Start SSH daemon
    echo "---> Starting SSH daemon..."
    /usr/sbin/sshd

    # Set up OnDemand directories
    echo "---> Setting up OnDemand directories..."
    mkdir -p /var/lib/ondemand-nginx/config/puns
    mkdir -p /var/log/ondemand-nginx
    mkdir -p /var/run/ondemand-nginx
    mkdir -p /var/tmp/ondemand-nginx
    
    # Ensure proper ownership
    chown -R ondemand-nginx:ondemand-nginx /var/lib/ondemand-nginx /var/log/ondemand-nginx /var/run/ondemand-nginx /var/tmp/ondemand-nginx 2>/dev/null || true
    
    # Ensure correct permissions for OnDemand apps
    chmod 755 /var/www/ood/apps/sys/projects 2>/dev/null || true

    # Update OnDemand portal configuration
    echo "---> Updating OnDemand portal configuration..."
    /opt/ood/ood-portal-generator/sbin/update_ood_portal

    # Start OnDemand Dex service (authentication) if available
    if [ -f /usr/sbin/ondemand-dex ] && [ -f /etc/ood/dex/config.yaml ]; then
        echo "---> Starting OnDemand Dex..."
        /usr/sbin/ondemand-dex serve /etc/ood/dex/config.yaml &
    else
        echo "---> Dex not configured, using Apache authentication instead"
    fi

    # Start Apache/httpd for OnDemand
    echo "---> Starting Apache httpd for OnDemand..."
    exec /usr/sbin/httpd -D FOREGROUND
fi

exec "$@"
