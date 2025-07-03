#!/bin/bash
set -e

# Initialize MUNGE if key doesn't exist
if [ ! -f /etc/munge/munge.key ]; then
    echo "Generating MUNGE key..."
    /usr/sbin/create-munge-key
    chown munge:munge /etc/munge/munge.key
    chmod 400 /etc/munge/munge.key
fi

# Start SSSD for LDAP authentication
echo "Starting SSSD..."
/usr/sbin/sssd -D

# Start MUNGE
echo "Starting MUNGE..."
/usr/sbin/munged -D

# Wait for MUNGE to be ready
sleep 2

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
