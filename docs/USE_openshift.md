# USE startx db-tools with s2i and openshift

This section will show you how to use sx-dbtools to build openshift build config 
for updating your database. If you wan to see other method, please visit our 
[official sxapi docker image](https://hub.docker.com/r/startx/db-tools/)

## Pre-requisises

To start working on openshift, please be sure you have :
- Git 
- Accès to a git SCM such as Github, Gitlab
- A openshift cluster running
- Developper access to this openshift plateform

### 1. Install and start docker + docker-compose
