# USE startx db-tools with docker

You can use startx db-tools within a container by using our public 
[official sxapi docker image](https://hub.docker.com/r/startx/db-tools/)

## Want to try ?

To try this application before working on it, the easiest way 
is to use the container version. Follow theses steps to run
a sxapi application within the next couple of minutes. 
(You can skip the first step if you already have [docker](https://www.docker.com)
installed and running)

### 1. Install and start docker

Theses command are for a Red Hat Linux like
environement (Fedora, CentOS, RHEL, Suse). Please adapt `yum` command to the 
```apt-get``` equivalent if you are using a Debian like system (Ubuntu, Debian)

```bash
sudo yum install -y docker
sudo service docker start
```
For more information on how to install and execute a docker runtime, please see
the [official docker installation guide](https://docs.docker.com/engine/installation/)
After installation, pay attention to your user authorisation. Your current user
must interact with the docker daemon.

### 2. Get the sxapi container image

Use docker command to get db-tools container image from the docker hub registry. 
This will update your local docker image cache.

```bash
docker pull startx/db-tools:latest
```

### 3. Create your database's init files 

Create the following file structure. 
You can skip the `mysql` directory if you don't plan to use this container with a mysql backend. 
You can skip the `couchbase` directory if you don't plan to use this container with a couchbase backend. 

```bash
mkdir mounts
mkdir mounts/mysql
touch mounts/mysql/schema.sql
touch mounts/mysql/data.sql
mkdir mounts/couchbase
touch mounts/couchbase/data.json
```

Example for `mounts/mysql/schema.sql`
```sql
DROP TABLE IF EXISTS `app`;
CREATE TABLE `app` (
  `id` int(4) unsigned NOT NULL AUTO_INCREMENT,
  `key` varchar(128) NOT NULL,
  `val` varchar(128) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `key` (`key`),
  KEY `val` (`val`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
```

Example for `mounts/mysql/data.sql`
```sql
SET names 'utf8';
LOCK TABLES `app` WRITE;
INSERT INTO `app` VALUES 
(1,'version','0');
UNLOCK TABLES;
```

Example for `mounts/couchbase/data.json`
```javascript
[
    {"_id":"app::version","app":"startx-db-tools","stage":"dev","version":"0.0.11"}
]
```

### 4. Run your application

without action

```bash
docker run -d \
    --link db-mysql:dbm \
    --link db-couchbase:dbc \
    startx/db-tools
```

or using environement variable and init global action

```bash
docker run -d \
    --link db-mysql:dbm \
    --link db-couchbase:dbc \
    -v ./mounts/mysql:/data/mysql:Z \
    -v ./mounts/couchbase:/data/couchbase:Z \
    --env MYSQL_DATABASE=dev \
    --env MYSQL_DATABASE_USER=dev \
    --env MYSQL_DATABASE_PASSWORD=dev \
    --env COUCHBASE_USER=dev \
    --env COUCHBASE_PASSWORD=dev \
    --env COUCHBASE_BUCKET=dev \
    startx/db-tools \
    init
```

### 6. See result

You can connect to your database backend to see created database or look at volumes 

## Container environement

### Container linked database

Only 2 backend are actually supported : 
- mysql : use mariadb 5.5 client and mysqldump. Should be based on 
- couchbase : use couchbase enterprise 4.5 client tools


| Param           | Mandatory | Type | default | Description
|-----------------|:---------:|:----:|---------|---------------
| **duration**    | no        | int  | 3600    | time in second for a session length. Could be used by transport (ex: cookie) or backend (ex: mysql) to control session duration. <br> If this time is exceed, session will return an error response. Used in conjunction with stop field property in mysql backend or cookie duration in cookie transport type.
| **auto_create** | no        | bool | false   | If transport type could not find a session ID, create a new session transparently
| **transport**   | no        | obj  | null    | An object describing the transport type used to get and set session ID. See [transport section](#transport-using-type)
| **backend**     | no        | obj  | null    | An object describing the backend type used to store and retrive session context. See [backend section](#backend-using-type)
