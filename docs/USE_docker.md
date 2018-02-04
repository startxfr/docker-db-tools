# USE startx db-tools with docker

You can use startx db-tools within a container by using our public 
[official sxapi docker image](https://hub.docker.com/r/startx/db-tools/)

## Want to try ?

To try this application before working on it, the easiest way 
is to use the container version. Follow theses steps to run
a startx dbtools within the next couple of minutes. 
(You can skip the first step if you already have [docker](https://www.docker.com)
installed and running).

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
mkdir dump
mkdir dump/mysql
touch dump/mysql/schema.sql
touch dump/mysql/data.sql
mkdir dump/couchbase
touch dump/couchbase/data.json
```

Example for `dump/mysql/schema.sql`
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

Example for `dump/mysql/data.sql`
```sql
SET names 'utf8';
LOCK TABLES `app` WRITE;
INSERT INTO `app` VALUES 
(1,'version','0');
UNLOCK TABLES;
```

Example for `dump/couchbase/data.json`
```javascript
[
    {"_id":"app::version","app":"sx-dbtools","stage":"dev","version":"0.1.14"}
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
    -v ./dump/mysql:/dump/mysql:Z \
    -v ./dump/couchbase:/dump/couchbase:Z \
    --env MYSQL_DATABASE=dev \
    --env MYSQL_USERS=dev:dev,dev2 \
    --env COUCHBASE_ADMIN=dev:dev \
    --env COUCHBASE_BUCKET=dev \
    startx/db-tools \
    recreate
```

### 6. See result

You can connect to your database backend to see created database or look at volumes 

## Connected services

you must tag properly the database service when you link your containers. 

| Link tag  | Description
|-----------|:------------
| dbm       | mysql container running offical `mariadb:5.5` image
| dbc       | couchbase container running offical `couchbase:couchbase:enterprise-5.0.1` image

Initialize mysql and couchbase linked database
```bash
docker run -d
--link db-mysql:dbm \                       # Linked mysql service
--link db-couchbase:dbc \                   # Linked couchbase service
-v ./backup:/backup:rw \                    # mounted volume with *schema.sql and *data.sql files
-v ./couchbase-data:/dump/couchbase:rw \    # mounted volume with *data.json files
-e MYSQL_DATABASE=demo \                    # List of mysql database to manipulate
-e MYSQL_ADMIN=root:rootPassword \          # mysql administrator username and password
-e COUCHBASE_ADMIN=demo:password \          # couchbase administrator username and password
-e COUCHBASE_BUCKET=demo,demo2 \            # List of couchbase bucket to manipulate
startx/db-tools                             # sx-dbtools docker image 
recreate                                    # sx-dbtools command
```

## Data volumes

you must use the appropriate data volumes and fill them with appropriate file to get your data
loaded or dumped properly.

| Container volume   | Description
|--------------------|:------------
| `/dump`            | volume containing a `mysql` directory and/or a `couchbase` directory
| `/backup`          | volume containing backup files

Dump mysql linked database into local directory
```bash
docker run -d
--link db-mysql:dbm \                       # Linked mysql service
-v ./mysql-data:/dump/mysql:rw \            # mounted volume with *schema.sql and *data.sql files
-e MYSQL_DATABASE=demo \                    # List of mysql database to manipulate
-e MYSQL_ADMIN=root:rootPassword \          # mysql administrator username and password
startx/db-tools                             # sx-dbtools docker image 
dump mysql                                  # sx-dbtools command
```
Dump couchbase linked bucket into local directory
```bash
docker run -d
--link db-mysql:dbm \                       # Linked mysql service
-v ./couchbase-data:/dump/couchbase:rw \    # mounted volume with *data.json files
-e COUCHBASE_ADMIN=demo:password \          # couchbase administrator username and password
-e COUCHBASE_BUCKET=demo,demo2 \            # List of couchbase bucket to manipulate
startx/db-tools                             # sx-dbtools docker image 
dump couchbase                              # sx-dbtools command
```

## Environement variables

Using environement variable you can customize this tools and use it to interact with
various kind of backend infrastructure (container, host, remote, IaaS, DBaaS)

| Variable                 | Default         | Description
|--------------------------|:---------------:|:---------------
| SXCMD                    |                 | If set, container will execute this command instead of the container command (ex: SXCMD="create mysql demo2" for creating the demo2 mysql database)
| SXDBTOOLS_DEBUG          | true            | Activate debugging display
| SXDBTOOLS_BACKUP_DIR     | /backup         | The final destination directory for backup
| SXDBTOOLS_DUMP_DIR       | /dump           | The final destination directory for dump
| MYSQL_DUMP_DIR           | /dump/mysql     | Directory used for save and restore mysql dump (container internal path)
| MYSQL_DUMP_DATAFILE      | data.sql        | Filename of the default sql data dump file 
| MYSQL_DUMP_SCHEMAFILE    | schema.sql      | Filename of the default sql schema dump file
| MYSQL_DUMP_ISEXTENDED    | true            | Enable smart extended dump for fast load, readibility and versioning
| MYSQL_HOST               | dbm             | Hostname of the mysql database. Could use whatever public IP or DSN.
| MYSQL_ADMIN              | [linked user]   | Mysql admin user and password (ex: user:password). Default will use root and MYSQL_ROOT_PASSWORD found into the linked container
| MYSQL_DATABASE           |                 | Mysql database name to use or create
| MYSQL_USERS              |                 | Mysql list of users to the database "," is separator between users and ":" between user and his password. ex : user:password,user2:user2Password,user3,user4
| COUCHBASE_DUMP_DIR       | /dump/couchbase | Directory used for save and restore couchbase dump (container internal path)
| COUCHBASE_DUMP_DATAFILE  | data.json       | Filename of the json data dump file
| COUCHBASE_HOST           | dbc             | Hostname of the couchbase database. Could use whatever public IP or DSN.
| COUCHBASE_ADMIN          | dev:dev         | Couchbase admin user and password (ex: user:password)
| COUCHBASE_USERS          |                 | Mysql list of users to the cluster "," is separator between users and ":" between user and his password. ex : user:password,user2:user2Password,user3,user4
| COUCHBASE_BUCKET         |                 | Couchbase bucket name to use or create

Create a database `demo` + user `demo_user`. Load sample schema and data into database
and allow `demo_user` to access this database only.
```bash
docker run -d --link db-mysql:dbm \
    --env MYSQL_DATABASE=demo \
    --env MYSQL_USERS=demo_user:pwd \
    startx/db-tools mysql create
```

Create a bucket `demo` and load sample data into bucket. If couchbase cluster is not initialized,
initialize it with a user 'cbAdmin'
```bash
docker run -d --link db-couchbase:dbc \
    --env COUCHBASE_ADMIN=cbAdmin:cbAdmin123 \
    --env COUCHBASE_BUCKET=demo \
    startx/db-tools couchbase create
```
