#!/bin/bash
# Initialize Slurm accounts and user associations with retry logic

set -euo pipefail

# Configuration
MAX_RETRIES=10
RETRY_DELAY=5
SLURMDBD_TIMEOUT=60

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to wait for slurmdbd to be ready
wait_for_slurmdbd() {
    local count=0
    log_info "Waiting for slurmdbd to be ready..."
    
    while [ $count -lt $SLURMDBD_TIMEOUT ]; do
        if sacctmgr -n show cluster &>/dev/null; then
            log_info "slurmdbd is ready!"
            return 0
        fi
        sleep 1
        count=$((count + 1))
        if [ $((count % 10)) -eq 0 ]; then
            log_warn "Still waiting for slurmdbd... ($count seconds)"
        fi
    done
    
    log_error "Timeout waiting for slurmdbd after $SLURMDBD_TIMEOUT seconds"
    return 1
}

# Function to execute sacctmgr commands with retry
execute_with_retry() {
    local command="$1"
    local description="$2"
    local retries=0
    
    while [ $retries -lt $MAX_RETRIES ]; do
        log_info "Attempting: $description (attempt $((retries + 1))/$MAX_RETRIES)"
        
        if eval "$command"; then
            log_info "Success: $description"
            return 0
        else
            retries=$((retries + 1))
            if [ $retries -lt $MAX_RETRIES ]; then
                log_warn "Failed, retrying in $RETRY_DELAY seconds..."
                sleep $RETRY_DELAY
            fi
        fi
    done
    
    log_error "Failed after $MAX_RETRIES attempts: $description"
    return 1
}

# Main initialization
main() {
    log_info "Starting Slurm account initialization..."
    
    # Wait for slurmdbd to be ready
    if ! wait_for_slurmdbd; then
        log_error "Cannot proceed without slurmdbd"
        exit 1
    fi
    
    # Create hpcadmin account if it doesn't exist
    if ! sacctmgr -n show account hpcadmin | grep -q hpcadmin; then
        execute_with_retry \
            "sacctmgr -i add account hpcadmin description='HPC Admin Account'" \
            "Create hpcadmin account"
    else
        log_info "Account 'hpcadmin' already exists"
    fi
    
    # Create hpcadmin user if it doesn't exist
    if ! sacctmgr -n show user hpcadmin | grep -q hpcadmin; then
        execute_with_retry \
            "sacctmgr -i add user hpcadmin account=hpcadmin" \
            "Create hpcadmin user with account associations"
    else
        log_info "User 'hpcadmin' already exists"
    fi
    
    # Verify associations were created correctly
    log_info "Verifying user associations..."
    if sacctmgr -n show associations user=hpcadmin | grep -q hpcadmin; then
        log_info "User associations verified successfully:"
        sacctmgr show associations user=hpcadmin
    else
        log_error "Failed to verify user associations!"
        exit 1
    fi
    
    # Create additional test users if needed
    for user in user1 user2; do
        if ! sacctmgr -n show user $user | grep -q $user; then
            log_info "Creating test user: $user"
            execute_with_retry \
                "sacctmgr -i add user $user account=hpcadmin" \
                "Create user $user"
        fi
    done
    
    log_info "Slurm account initialization completed successfully!"
}

# Run main function
main "$@"
