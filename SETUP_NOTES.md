# Open OnDemand Demo Setup Notes

This demo environment runs Open OnDemand 4.0+ on Rocky Linux 9 without XDMoD or ColdFront dependencies.

## Quick Start

1. Ensure Docker is running on your system
2. Clone this repository
3. Run the setup:
   ```bash
   ./hpcts start
   ```
4. Wait for all services to start (about 30 seconds)
5. Access Open OnDemand at https://localhost:3443

## Login Credentials

Use these credentials to log into Open OnDemand:
- Username: `hpcadmin`
- Password: `ilovelinux`

Other available users:
- `cgray` (password: `test123`)
- `sfoster` (password: `ilovelinux`)
- `csimmons` (password: `ilovelinux`)
- `astewart` (password: `ilovelinux`)

## SSH Access

You can SSH into the frontend node:
```bash
ssh -p 6222 hpcadmin@localhost
```

## Architecture Changes from UBCCR Version

1. **Base OS**: Upgraded from CentOS to Rocky Linux 9
2. **Open OnDemand**: Upgraded to version 4.0.5
3. **Authentication**: Switched from LDAP to file-based authentication for simplicity
4. **Removed Components**: XDMoD and ColdFront have been completely removed

## Key Configuration Files

- `docker-compose.yml` - Main orchestration file
- `ondemand-v2/Dockerfile` - OnDemand container definition
- `ondemand-v2/entrypoint.sh` - Container initialization script
- `ondemand-v2/ood_portal.yml` - OnDemand portal configuration
- `ondemand-v2/nginx_stage.yml` - Nginx stage configuration

## Building Images

If you need to rebuild the images:

```bash
# Build base image
cd base-v2
docker build -t gbuchanan/hpc-demo:base-v2-2025.07 .

# Build LDAP image
cd ../ldap
docker build -t gbuchanan/hpc-demo:ldap-v2-2025.07 .

# Build Slurm image
cd ../slurm-v2
docker build -t gbuchanan/hpc-demo:slurm-v2-2025.07 --build-arg DOCKER_USER=gbuchanan/hpc-demo --build-arg HPCTS_VERSION=2025.07 .

# Build OnDemand image
cd ../ondemand-v2
docker build -t gbuchanan/hpc-demo:ondemand-v2-2025.07 --build-arg DOCKER_USER=gbuchanan/hpc-demo --build-arg HPCTS_VERSION=2025.07 .
```

## Troubleshooting

If you encounter issues:

1. Check that all containers are running:
   ```bash
   docker ps
   ```

2. Check container logs:
   ```bash
   docker logs ondemand
   docker logs frontend
   docker logs slurmctld
   ```

3. Restart the environment:
   ```bash
   ./hpcts destroy
   ./hpcts start
   ```

## Known Issues Resolved

- ✅ MUNGE permissions are automatically fixed on startup
- ✅ Users are automatically created in all containers
- ✅ nginx path is correctly configured for OnDemand 4.0
- ✅ Authentication uses simple file-based auth instead of LDAP
