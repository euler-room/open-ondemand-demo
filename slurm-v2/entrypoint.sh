#!/bin/bash
set -e

# Function to start MUNGE with retries
start_munge() {
    local attempt=1
    local max_attempts=3
    
    echo "Setting up MUNGE..."
    
    while [ $attempt -le $max_attempts ]; do
        echo "  -> Attempt $attempt to start MUNGE..."
        
        # Clean up any existing state
        killall munged 2>/dev/null || true
        rm -rf /var/run/munge /var/log/munge
        
        # Create directories with proper ownership
        mkdir -p /var/lib/munge /var/log/munge /var/run/munge /etc/munge
        chown -R munge:munge /var/lib/munge /var/log/munge /var/run/munge /etc/munge
        chmod 755 /var/lib/munge /var/run/munge
        chmod 700 /var/log/munge /etc/munge
        
        # Initialize MUNGE if key doesn't exist
        if [ ! -f /etc/munge/munge.key ]; then
            echo "  -> Generating MUNGE key..."
            /usr/sbin/create-munge-key
            chown munge:munge /etc/munge/munge.key
            chmod 400 /etc/munge/munge.key
        fi
        
        # Start MUNGE with proper user context
        if gosu munge /usr/sbin/munged --force --syslog; then
            sleep 2
            # Test if MUNGE is working
            if /usr/bin/munge -n >/dev/null 2>&1; then
                echo "  -> MUNGE started successfully!"
                return 0
            fi
        fi
        
        echo "  -> MUNGE failed to start on attempt $attempt"
        attempt=$((attempt + 1))
        sleep 2
    done
    
    echo "ERROR: Failed to start MUNGE after $max_attempts attempts!"
    return 1
}

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

# Create local demo users for SSH access (demo environment only)
echo "Creating demo users for SSH access..."
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

# Start MUNGE with error handling
if ! start_munge; then
    echo "ERROR: MUNGE is required for Slurm operation!"
    exit 1
fi

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
        # Run account initialization in background
        if [ -x /usr/local/bin/init-accounts.sh ]; then
            /usr/local/bin/init-accounts.sh &
        fi
        exec /usr/sbin/slurmctld -D
        ;;
    slurmd)
        echo "Starting slurmd..."
        exec /usr/sbin/slurmd -D
        ;;
    frontend)
        echo "Starting frontend (SSH)..."
        mkdir -p /etc/ssh
        ssh-keygen -A 2>/dev/null || true
        exec /usr/sbin/sshd -D
        ;;
    *)
        echo "Usage: $0 {slurmdbd|slurmctld|slurmd|frontend}"
        exit 1
        ;;
esac
