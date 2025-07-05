# Open OnDemand Demo

This demo provides a complete HPC cluster environment with Open OnDemand 4.0+ web interface, SLURM job scheduler, and LDAP authentication, all running in Docker containers.

## What's Included

The demo environment includes:

* [Open OnDemand 4.0+](https://openondemand.org) - Full-featured web portal for HPC clusters
* [SLURM](https://slurm.schedmd.com) - Workload manager and job scheduler 
* [LDAP](https://www.openldap.org/) - Directory service for user authentication
* [munge](https://dun.github.io/munge/) - SLURM authentication service
* [Lmod](https://lmod.readthedocs.io) - Environment module system

## Quick Start

1. **Clone the repository:**
   ```bash
   git clone https://github.com/gbuchanan/open-ondemand-demo.git
   cd open-ondemand-demo
   ```

2. **Start the demo:**
   ```bash
   ./hpcts start
   ```

3. **Access the services:**
   - **OnDemand Web Interface**: https://localhost:3443
   - **SSH Access**: `ssh -p 6222 hpcadmin@localhost` (password: ilovelinux)

## Services & Architecture

- **Frontend Node**: SSH access point and job submission
- **Compute Nodes**: cpn01, cpn02 - SLURM worker nodes
- **OnDemand Node**: Web portal with full OnDemand functionality
- **SLURM Controller**: slurmctld and slurmdbd services
- **LDAP**: User directory and authentication
- **MySQL**: Database backend for SLURM accounting

## Management Commands

```bash
./hpcts start     # Start all services
./hpcts stop      # Stop all services
./hpcts destroy   # Stop and remove containers/volumes
./hpcts cleanup   # Remove images (requires confirmation)
```

## Docker Images

All images are available on DockerHub:
- `gbuchanan/hpc-demo:base-v2-2025.07`
- `gbuchanan/hpc-demo:ldap-v2-2025.07`
- `gbuchanan/hpc-demo:slurm-v2-2025.07`
- `gbuchanan/hpc-demo:ondemand-v2-2025.07`

## User Accounts

Pre-configured LDAP users:
- **hpcadmin** (admin user)
- **cgray** (regular user)
- **sfoster** (regular user)
- **ccampbell** (regular user)

All users have the password: `ilovelinux`

## OnDemand Features

The demo includes a fully functional OnDemand instance with:
- Job submission and monitoring
- File management
- Interactive applications
- Shell access
- Job templates and workflows

## System Requirements

- Docker and Docker Compose
- 8GB+ RAM recommended
- 20GB+ disk space for images and data

## Disclaimer

**DO NOT run this project on production systems.** This project is for educational
purposes only. The container images we publish for the tutorial are configured
with hard coded insecure passwords and should be run locally in development for
testing and learning only. 

## License

This project is released under the GPLv3 license. See the LICENSE file.

## Based On

This demo is derived from the [HPC Toolset Tutorial](https://github.com/ubccr/hpc-toolset-tutorial) 
by University at Buffalo CCR and Ohio Supercomputer Center.
