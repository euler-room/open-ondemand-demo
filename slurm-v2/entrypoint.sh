#!/bin/bash
set -e

# Fix MUNGE directory permissions
echo "Setting up MUNGE..."
chown -R munge:munge /var/lib/munge /var/log/munge /var/run/munge /etc/munge
chmod 755 /var/lib/munge /var/run/munge
chmod 700 /var/log/munge /etc/munge

# Initialize MUNGE if key doesn't exist
if [ ! -f /etc/munge/munge.key ]; then
    echo "Generating MUNGE key..."
    /usr/sbin/create-munge-key
    chown munge:munge /etc/munge/munge.key
    chmod 400 /etc/munge/munge.key
fi

# Set up SLURM directories and permissions
echo "Setting up SLURM directories..."
mkdir -p /var/spool/slurmd /var/log/slurm /var/lib/slurm /var/run/slurm /etc/slurm
chown -R slurm:slurm /var/spool/slurmd /var/log/slurm /var/lib/slurm /var/run/slurm /etc/slurm
chmod 755 /var/spool/slurmd /var/log/slurm /var/lib/slurm /var/run/slurm
chmod 600 /etc/slurm/slurmdbd.conf 2>/dev/null || true
chown slurm:slurm /etc/slurm/slurmdbd.conf 2>/dev/null || true

# Start SSSD for LDAP authentication  
echo "Starting SSSD..."
/usr/sbin/sssd -D

# Start MUNGE with proper user context
echo "Starting MUNGE..."
gosu munge /usr/sbin/munged &

# Wait for MUNGE to be ready
sleep 3

# Execute the requested service
case "$1" in
    slurmdbd)
        echo "Starting slurmdbd..."
        exec /usr/sbin/slurmdbd -D
        ;;
    slurmctld)
        echo "Starting slurmctld..."
        exec /usr/sbin/slurmctld -D
        ;;
    slurmd)
        echo "Starting slurmd..."
        exec /usr/sbin/slurmd -D
        ;;
    frontend)
        echo "Starting frontend (SSH)..."
        /usr/sbin/sshd-keygen -A 2>/dev/null || true
        exec /usr/sbin/sshd -D
        ;;
    *)
        echo "Usage: $0 {slurmdbd|slurmctld|slurmd|frontend}"
        exit 1
        ;;
esac
