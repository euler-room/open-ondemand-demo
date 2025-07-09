## Accessing the Applications

Now that your containers have been created and applications launched, you can login to them using your browser and via SSH.  We recommend you keep this page open as you work your way through the tutorial as it provides a guide to URLs, container names, and user credentials.

**At this point, you can begin exploring Open OnDemand!**


### User Accounts

By default, all containers authenticate to LDAP and you can login to them via ssh, and for the OnDemand container, also through your browser.  Details for each software package are listed below.

Default password for all accounts (except cgray): `ilovelinux`

- hpcadmin
- cgray (password: test123)
- sfoster
- csimmons
- astewart

### Cluster Frontend

Login to frontend via SSH and user: `hpcadmin` password: `ilovelinux`:
```
ssh -p 6222 hpcadmin@localhost
```  
**NOTE: You must login to the front end before trying to login to any of the other containers!**

### Single-sign on: Portal login/logout
Because these applications are configured for single-sign on (SSO), if you login using Dex/OpenID Connect and want to switch between users you will either need to clear the browser cookies or restart the browser.  You may wish to launch multiple 'incognito' windows for each user account used in the tutorial and switch between them as you go.


### Open OnDemand

Open OnDemand is used for accessing HPC resources, submitting jobs to a cluster, user file access, etc.

SSH container name: ondemand (must login to front end first)  
URL: https://localhost:3443  
*Portal Logins include:*  
Any of the LDAP accounts listed above.  
Once logged in, click on "Clusters" and then "HPC Cluster Shell Access" and you will be logged in to the cluster frontend container.



### Slurm and Compute Nodes

There is a slurm controller, slurm database container, and two compute nodes in this cluster.

Login to the front end first:
`ssh -p 6222 hpcadmin@localhost`

Then login to any of the containers using any of the LDAP accounts listed above.  

SSH container name for Slurm controller: `slurmctld`  
SSH container name for Slurm database: `slurmdbd`  
SSH container name for compute node 1: `cpn01`  
SSH container name for compute node 2: `cpn02`  




## Tutorial Navigation
[Previous Step - Getting Started](getting_started.md)  
[Docker Tips](docker_tips.md)  
[Back to Start](../README.md)
