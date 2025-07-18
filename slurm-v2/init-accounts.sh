#!/bin/bash
# Script to initialize Slurm accounts with robust retry logic
# This script is run automatically when slurmctld starts

set -euo pipefail

# Configuration
MAX_RETRIES=10
RETRY_DELAY=5
SLURMDBD_TIMEOUT=60

# Function to wait for slurmdbd to be ready
wait_for_slurmdbd() {
    local count=0
    echo "[$(date)] Waiting for slurmdbd to be ready..."
    
    while [ $count -lt $SLURMDBD_TIMEOUT ]; do
        if sacctmgr -n show cluster &>/dev/null; then
            echo "[$(date)] slurmdbd is ready!"
            return 0
        fi
        sleep 1
        count=$((count + 1))
        if [ $((count % 10)) -eq 0 ]; then
            echo "[$(date)] Still waiting for slurmdbd... ($count seconds)"
        fi
    done
    
    echo "[$(date)] ERROR: Timeout waiting for slurmdbd after $SLURMDBD_TIMEOUT seconds"
    return 1
}

# Function to execute sacctmgr commands with retry
execute_with_retry() {
    local command="$1"
    local description="$2"
    local retries=0
    
    while [ $retries -lt $MAX_RETRIES ]; do
        echo "[$(date)] Attempting: $description (attempt $((retries + 1))/$MAX_RETRIES)"
        
        if eval "$command"; then
            echo "[$(date)] Success: $description"
            return 0
        else
            retries=$((retries + 1))
            if [ $retries -lt $MAX_RETRIES ]; then
                echo "[$(date)] Failed, retrying in $RETRY_DELAY seconds..."
                sleep $RETRY_DELAY
            fi
        fi
    done
    
    echo "[$(date)] ERROR: Failed after $MAX_RETRIES attempts: $description"
    return 1
}

# Main initialization
echo "[$(date)] Starting Slurm account initialization..."

# Wait for slurmdbd to be ready
if ! wait_for_slurmdbd; then
    echo "[$(date)] ERROR: Cannot proceed without slurmdbd"
    exit 1
fi

# Check if hpcadmin account exists
if ! sacctmgr show account hpcadmin -n | grep -q hpcadmin; then
    execute_with_retry \
        "sacctmgr -i add account hpcadmin description='HPC Admin Account'" \
        "Create hpcadmin account"
    
    # Add root user to hpcadmin account
    execute_with_retry \
        "sacctmgr -i add user root account=hpcadmin" \
        "Add root user to hpcadmin account"
else
    echo "[$(date)] hpcadmin account already exists."
fi

# Add demo users to hpcadmin account
for user in hpcadmin cgray sfoster csimmons astewart; do
    if ! sacctmgr show user $user -n | grep -q $user; then
        execute_with_retry \
            "sacctmgr -i add user $user account=hpcadmin" \
            "Add user $user to hpcadmin account"
    else
        echo "[$(date)] User $user already exists in Slurm."
    fi
done

echo "[$(date)] Slurm account initialization completed!"
