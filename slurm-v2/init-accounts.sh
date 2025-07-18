#!/bin/bash
# Script to initialize Slurm accounts
# This script is run after slurmctld starts

# Wait for slurmctld to be fully ready
sleep 10

# Check if hpcadmin account exists
if ! sacctmgr show account hpcadmin -n | grep -q hpcadmin; then
    echo "Creating hpcadmin account..."
    sacctmgr -i add account hpcadmin description="HPC Admin Account"
    
    # Add root user to hpcadmin account
    sacctmgr -i add user root account=hpcadmin
    
    echo "hpcadmin account created successfully."
else
    echo "hpcadmin account already exists."
fi
