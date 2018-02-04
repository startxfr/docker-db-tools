# USE startx db-tools with docker-compose

You can use startx db-tools within a container by using our public 
[official sxapi docker image](https://hub.docker.com/r/startx/db-tools/)

## Want to try ?

To try this application before working on it, the easiest way 
is to use the container version. Follow theses steps to run
a startx dbtools within the next couple of minutes. 
(You can skip the first step if you already have [docker](https://www.docker.com)
installed and running)<br>

If your're experienced with docker and docker-compose, you can read our 
[full stack example](./docker-compose_sample-full.yml),
[simple example](./docker-compose_sample-simple.yml), [mysql example](./docker-compose_sample-mysql.yml)
or [couchbase example](./docker-compose_sample-couchbase.yml) and start reading
the [linked service section](#linked-services).

### 1. Install and start docker + docker-compose

Theses command are for a Red Hat Linux like
environement (Fedora, CentOS, RHEL, Suse). Please adapt `yum` command to the 
```apt-get``` equivalent if you are using a Debian like system (Ubuntu, Debian)

```bash
sudo yum install -y docker docker-compose
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
mkdir backup
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
    {"_id":"app::version","app":"sx-dbtools","stage":"dev","version":"0.1.16"}
]
```

### 4. Create your docker-compose.yml

```yaml
app:
  image: startx/db-tools:latest
  container_name: "sx-dbtools"
  links:
    - db-mysql:dbm
    - db-couchbase:dbc
  command: ["create"]

db-mysql:
  image: mariadb:5.5
  container_name: "sx-dbtools_mysql"
  environment:
   - MYSQL_ROOT_PASSWORD=rootPassword
   
db-couchbase:
  image: couchbase:enterprise-5.0.1
  container_name: "sx-dbtools_couchbase"
```

### 5. Run your application

without action (defined in compose file)

```bash
docker-compose run -d;
docker-compose logs;
```

### 6. See result

You can connect to your database backend to see created database or look at volumes 


## Container environement

### Linked services

you must tag properly the database service when you link your containers. 

| Link tag  | Description
|-----------|:------------
| dbm       | mysql container running offical `mariadb:5.5` image
| dbc       | couchbase container running offical `couchbase:couchbase:enterprise-5.0.1` image

Initialize mysql and couchbase linked database
```yaml
app:                                        # docker-compose service name
  image: startx/db-tools:latest             # sx-dbtools container image
  container_name: "sx-dbtools"              # your running container name
  links:                                    # enable link to databases services
    - db-mysql:dbm                          # link to mysql database (named dbm)
    - db-couchbase:dbc                      # link to couchbase database (named dbc)
  volumes:                                  # enable volumes for dump and backup
    - "./:/dump:rw"                         # mounted volumes for dump and import mysql (*.sql) and couchbase (*.json)
  environment:                              # enable configuration of environment variables
   - MYSQL_DATABASE=demo                    # mysql databases names
   - MYSQL_ADMIN=demo:password              # user and password of the mysql admin user
   - COUCHBASE_ADMIN=cbAdmin:password       # user and password of the couchbase admin user
   - COUCHBASE_BUCKET=demo                  # couchbase buckets names
  command: ["recreate"]                     # sx-dbtools command
```

## Data volumes

you must use the appropriate data volumes and fill them with appropriate file to get your data
loaded or dumped properly.

| Container volume   | Description
|--------------------|:------------
| `/dump`            | volume containing a `mysql` directory and/or a `couchbase` directory
| `/backup`          | volume containing backup files

Dump mysql linked database into local directory
```yaml
app:                                        # docker-compose service name
  image: startx/db-tools:latest             # sx-dbtools container image
  container_name: "sx-dbtools"              # your running container name
  links:                                    # enable link to databases services
    - db-mysql:dbm                          # link to mysql database (named dbm)
  volumes:                                  # enable volumes for dump and backup
    - "./:/dump/mysql:rw"                   # volumes for mysql dump (*.sql)
  command: ["dump", "mysql"]                # sx-dbtools command
```

Dump couchbase linked bucket into local directory
```yaml
app:                                        # docker-compose service name
  image: startx/db-tools:latest             # sx-dbtools container image
  container_name: "sx-dbtools"              # your running container name
  links:                                    # enable link to databases services
    - db-couchbase:dbc                      # link to couchbase database (named dbc)
  volumes:                                  # enable volumes for dump and backup
    - "./:/dump/couchbase:rw"               # volumes for couchbase dump (*.json)
  command: ["dump", "couchbase"]            # sx-dbtools command
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
```yaml
app:                                        # docker-compose service name
  image: startx/db-tools:latest             # sx-dbtools container image
  container_name: "sx-dbtools"              # your running container name
  links:                                    # enable link to databases services
    - db-mysql:dbm                          # link to mysql database (named dbm)
  volumes:                                  # enable volumes for dump and backup
    - "./:/dump/mysql:rw"                   # volumes for mysql dump (*.sql)
  environment:                              # enable configuration of environment variables
   - MYSQL_DATABASE=demo                    # mysql databases names
   - MYSQL_ADMIN=demo:password              # user and password of the mysql admin user
   - MYSQL_USERS=demoUser:demPwd1,demoUser2 # users to create
  command: ["create" , "mysql"]             # sx-dbtools command
```

Create a bucket `demo` and load sample data into bucket. If couchbase cluster is not initialized,
initialize it with a user 'cbAdmin'
```yaml
app:                                        # docker-compose service name
  image: startx/db-tools:latest             # sx-dbtools container image
  container_name: "sx-dbtools"              # your running container name
  links:                                    # enable link to databases services
    - db-couchbase:dbc                      # link to couchbase database (named dbc)
  volumes:                                  # enable volumes for dump and backup
    - "./:/dump/mysql:rw"                   # volumes for mysql dump (*.sql)
  environment:                              # enable configuration of environment variables
   - COUCHBASE_ADMIN=cbAdmin:password       # user and password of the couchbase admin user
   - COUCHBASE_BUCKET=demo                  # couchbase buckets names
  command: ["create" , "couchbase"]         # sx-dbtools command
```
