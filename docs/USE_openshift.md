# USE startx db-tools with docker-compose

This user guide will help you run [sx-dbtools](https://github.com/startxfr/docker-db-tools) by running the [startx/db-tools](https://hub.docker.com/r/startx/db-tools/) container image using the docker runtime only.

## Requirements

This user guide require to have access to a linux system (Red Hat like is recommended). You must also have access to an openshift cluster with write access to at least one project. This section doesn't cover the installation of Openshift.
To test if you have acess to an openshift cluster, you can execute `oc login -u ≤user> -p <pwd> <cluster-url>`

## Install server environement

Theses command are for a Red Hat Linux like environement (Fedora, CentOS, RHEL, Suse). Please adapt `yum` command to the `apt-get` equivalent if you are using a Debian like system (Ubuntu, Debian)

### 1. Install oc client

```bash
sudo yum install -y openshift-cli
```

### 2. Test openshift client

```bash
oc version
# return : oc v1.3.1 \n kubernetes v1.3.0+52492b4
```

### 3. Connect to openshift cluster

```bash
oc login -u ≤user> -p <pwd> <cluster-url>
```

For more information on how to install and execute an openshift client, please see the [official openshift project](https://docs.openshift.com)

## Preparing sx-dbtools

### 1. Create your openshift project

```bash
oc new-project dbtools-test
```

### 2. Create your database's init files

Create the following file structure. You can skip the `mysql` directory if you don't plan to use this container with a mysql backend. You can skip the `couchbase` directory if you don't plan to use this container with a couchbase backend.

```bash
mkdir ~/dump
mkdir ~/dump/mysql
touch ~/dump/mysql/schema.sql
touch ~/dump/mysql/data.sql
mkdir ~/dump/couchbase
touch ~/dump/couchbase/data.json
mkdir ~/backup
```

#### Example for `~/dump/mysql/schema.sql`

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

#### Example for `~/dump/mysql/data.sql`

```sql
SET names 'utf8';
LOCK TABLES `app` WRITE;
INSERT INTO `app` VALUES
(1,'version','0');
UNLOCK TABLES;
```

#### Example for `~/dump/couchbase/data.json`

```javascript
[{ _id: "app::version", app: "sx-dbtools", stage: "dev", version: "0.1.38" }];
```

### 3. Create your docker-compose.yml

```yaml
app: # docker-compose service name for application
  image: startx/db-tools:latest # sx-dbtools container image for application
  container_name: "sx-dbtools" # your running container name
  links: # enable link to databases services
    - db-mysql:dbm # link to mysql database (named dbm)
    - db-couchbase:dbc # link to couchbase database (named dbc)
  command: ["create"] # sx-dbtools command

db-mysql: # docker-compose service name for mysql database
  image: mariadb:10.0 # sx-dbtools container image for mysql
  container_name: "sx-dbtools_mysql" # mysql container name
  environment: # enable configuration of environment variables
    - MYSQL_ROOT_PASSWORD=rootPassword # password of the mysql root user

db-couchbase: # docker-compose service name for couchbase database
  image: couchbase:enterprise-5.5.2 # sx-dbtools container image for couchbase
  container_name: "sx-dbtools_couchbase" # couchbase container name
```

## Running sx-dbtools

### 1. Run your database(s) service(s)

#### Start Mysql container

If you want to use sx-dbtools with a mysql database, you can run this command to start a mysql container based on the official mariadb image.

```yaml
db-mysql: # docker-compose service name for mysql database
  image: mariadb:10.0 # sx-dbtools container image for mysql
  container_name: "sx-dbtools_mysql" # mysql container name
  environment: # enable configuration of environment variables
    - MYSQL_ROOT_PASSWORD=rootPassword # password of the mysql root user
```

```bash
docker-compose run -d db-mysql;             # run mysql database service
```

#### Start Couchbase container

If you want to use sx-dbtools with a couchbase cluster, you can run this command to start a couchbase container based on the official couchbase image.

```yaml
db-couchbase: # docker-compose service name for couchbase database
  image: couchbase:enterprise-5.5.2 # sx-dbtools container image for couchbase
  container_name: "sx-dbtools_couchbase" # couchbase container name
```

```bash
docker-compose run -d db-couchbase;         # run couchbase database service
```

### 2. Run your sx-dbtools service

#### without action

```bash
docker-compose run app;                     # default command defined in docker-compose.yml or default in container image (welcome)
```

#### get container informations

```yaml
app: # docker-compose service name
  image: startx/db-tools:latest # sx-dbtools container image
  environment: # enable configuration of environment variables
    - SXDBTOOLS_DEBUG=true # activate debug info
  command: ["info"] # sx-dbtools command
```

```bash
docker-compose run app;                     # run the service
```

#### Link to databases, create user(s), database(s) and load content from volumes

```yaml
app: # docker-compose service name
  image: startx/db-tools:latest # sx-dbtools container image
  links: # enable link to databases services
    - db-mysql:dbm # link to mysql database (named dbm)
    - db-couchbase:dbc # link to couchbase database (named dbc)
  volumes: # enable volumes for dump and backup
    - "~/:/dump:z" # mounted volumes for dump and import mysql (*.sql) and couchbase (*.json)
  environment: # enable configuration of environment variables
    - MYSQL_DATABASE=demo,demo2 # mysql databases names
    - MYSQL_ADMIN=demo:password # user and password of the mysql admin user
    - MYSQL_USERS=demo:pwd,user3:pwd3,test # List of mysql user (password optional) to manipulate
    - COUCHBASE_ADMIN=cbAdmin:password # user and password of the couchbase admin user
    - COUCHBASE_BUCKET=demo,demo2 # couchbase buckets names
    - COUCHBASE_USERS=demo1:password1,demo2 # List of couchbase user (password optional) to manipulate
  command: ["recreate"] # sx-dbtools command
```

```bash
docker-compose run -d db-mysql db-couchbase;# run databases services
docker-compose run app;                     # run the service
```

### 3. See result

You can connect to your database backend to see created database or look at volumes

## Container environement

### Linked services

you must tag properly the database service when you link your containers.

| Link tag | Description                                                 |
| -------- | :---------------------------------------------------------- |
| dbm      | mysql container running offical `mariadb:10.0` image        |
| dbc      | couchbase container running offical `couchbase:5.5.2` image |

#### Examples

## Data volumes

you must use the appropriate data volumes and fill them with appropriate file to get your data
loaded or dumped properly.

| Container volume | Description                                                          |
| ---------------- | :------------------------------------------------------------------- |
| `/dump`          | volume containing a `mysql` directory and/or a `couchbase` directory |
| `/backup`        | volume containing backup files                                       |

#### Examples

## Environement variables

Using environement variable you can customize this tools and use it to interact with
various kind of backend infrastructure (container, host, remote, IaaS, DBaaS)

| Variable                |     Default     | Description                                                                                                                                                  |
| ----------------------- | :-------------: | :----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| SXCMD                   |                 | If set, container will execute this command instead of the container command (ex: SXCMD="create mysql demo2" for creating the demo2 mysql database)          |
| SXDBTOOLS_DEBUG         |      true       | Activate debugging display                                                                                                                                   |
| SXDBTOOLS_BACKUP_DIR    |     /backup     | The final destination directory for backup                                                                                                                   |
| SXDBTOOLS_DUMP_DIR      |      /dump      | The final destination directory for dump                                                                                                                     |
| MYSQL_DUMP_DIR          |   /dump/mysql   | Directory used for save and restore mysql dump (container internal path)                                                                                     |
| MYSQL_DUMP_DATAFILE     |    data.sql     | Filename of the default sql data dump file                                                                                                                   |
| MYSQL_DUMP_SCHEMAFILE   |   schema.sql    | Filename of the default sql schema dump file                                                                                                                 |
| MYSQL_DUMP_ISEXTENDED   |      true       | Enable smart extended dump for fast load, readibility and versioning                                                                                         |
| MYSQL_HOST              |       dbm       | Hostname of the mysql database. Could use whatever public IP or DSN.                                                                                         |
| MYSQL_ADMIN             |  [linked user]  | Mysql admin user and password (ex: user:password). Default will use root and MYSQL_ROOT_PASSWORD found into the linked container                             |
| MYSQL_DATABASE          |                 | Mysql database name to use or create                                                                                                                         |
| MYSQL_USERS             |                 | Mysql list of users to the database "," is separator between users and ":" between user and his password. ex : user:password,user2:user2Password,user3,user4 |
| COUCHBASE_DUMP_DIR      | /dump/couchbase | Directory used for save and restore couchbase dump (container internal path)                                                                                 |
| COUCHBASE_DUMP_DATAFILE |    data.json    | Filename of the json data dump file                                                                                                                          |
| COUCHBASE_HOST          |       dbc       | Hostname of the couchbase database. Could use whatever public IP or DSN.                                                                                     |
| COUCHBASE_ADMIN         |     dev:dev     | Couchbase admin user and password (ex: user:password)                                                                                                        |
| COUCHBASE_USERS         |                 | Mysql list of users to the cluster "," is separator between users and ":" between user and his password. ex : user:password,user2:user2Password,user3,user4  |
| COUCHBASE_BUCKET        |                 | Couchbase bucket name to use or create                                                                                                                       |

#### Examples

## Actions you can perform

### Global Commands

| Command  | database-type   | options  | Description                                                                                   |
| -------- | --------------- | -------- | --------------------------------------------------------------------------------------------- |
| create   |                 |          | Create all user(s) + database(s) + data for all database type                                 |
| create   | mysql/couchbase |          | Create all user(s) + database(s) + data for one database type (mysql or couchbase)            |
| create   | mysql/couchbase | database | Create one database + data for one database type (mysql or couchbase)                         |
| delete   |                 |          | Delete all user(s) + database(s) + data for all database type                                 |
| delete   | mysql/couchbase |          | Delete all user(s) + database(s) + data for one database type (mysql or couchbase)            |
| delete   | mysql/couchbase | database | Delete one database + data for one database type (mysql or couchbase)                         |
| recreate |                 |          | Delete and create all user(s) + database(s) + data for all database type                      |
| recreate | mysql/couchbase |          | Delete and create all user(s) + database(s) + data for one database type (mysql or couchbase) |
| recreate | mysql/couchbase | database | Delete and create one database + data for one database type (mysql or couchbase)              |

#### Examples

### Data Commands

| Command     | database-type   | options  | Description                                                  |
| ----------- | --------------- | -------- | ------------------------------------------------------------ |
| dump        |                 |          | Dump all database(s) AND all bucket(s) in dump directory     |
| dump        | mysql/couchbase |          | Dump all database(s) OR all bucket(s) in dump directory      |
| dump        | mysql/couchbase | database | Dump only one database or bucket in dump directory           |
| import      |                 |          | import all database(s) AND all bucket(s) from dump directory |
| import      | mysql/couchbase |          | import all database(s) OR all bucket(s) from dump directory  |
| import      | mysql/couchbase | database | import database(s) from dump directory                       |
| create-data |                 |          | alias of import command                                      |

#### Examples

### Backup / Restore Commands

| Command | database-type   | options  | Description                                                                   |
| ------- | --------------- | -------- | ----------------------------------------------------------------------------- |
| backup  |                 |          | Backup database(s) in backup directory (not implemented)                      |
| backup  | mysql/couchbase |          | Backup all database(s) or all bucket(s) in backup directory (not implemented) |
| backup  | mysql/couchbase | database | Backup one database or bucket in backup directory (not implemented)           |
| restore | archivename.tgz |          | Restore database(s) in backup directory (not implemented)                     |

#### Examples

### Database Commands

| Command     | database-type   | options  | Description                                                                  |
| ----------- | --------------- | -------- | ---------------------------------------------------------------------------- |
| create-db   |                 |          | Create all database(s) for all database type                                 |
| create-db   | mysql/couchbase |          | Create all database(s) for one database type (mysql or couchbase)            |
| create-db   | mysql/couchbase | database | Create one database for one database type (mysql or couchbase)               |
| delete-db   |                 |          | Delete all database(s) for all database type                                 |
| delete-db   | mysql/couchbase |          | Delete all database(s) for one database type (mysql or couchbase)            |
| delete-db   | mysql/couchbase | database | Delete one database for one database type (mysql or couchbase)               |
| recreate-db |                 |          | Delete and create all database(s) for all database type                      |
| recreate-db | mysql/couchbase |          | Delete and create all database(s) for one database type (mysql or couchbase) |
| recreate-db | mysql/couchbase | database | Delete and create one database for one database type (mysql or couchbase)    |

#### Examples

### User management Commands

| Command       | database-type   | options | Description                                                              |
| ------------- | --------------- | ------- | ------------------------------------------------------------------------ |
| create-user   |                 |         | Create all user(s) for all database type                                 |
| create-user   | mysql/couchbase |         | Create all user(s) for one database type (mysql or couchbase)            |
| create-user   | mysql/couchbase | user    | Create one user for one database type (mysql or couchbase)               |
| delete-user   |                 |         | Delete all user(s) for all database type                                 |
| delete-user   | mysql/couchbase |         | Delete all user(s) for one database type (mysql or couchbase)            |
| delete-user   | mysql/couchbase | user    | Delete one user for one database type (mysql or couchbase)               |
| recreate-user |                 |         | Delete and create all user(s) for all database type                      |
| recreate-user | mysql/couchbase |         | Delete and create all user(s) for one database type (mysql or couchbase) |
| recreate-user | mysql/couchbase | user    | Delete and create one user for one database type (mysql or couchbase)    |

#### Examples

### sx-dbtools Commands

| Command | database-type | options | Description                                   |
| ------- | ------------- | ------- | --------------------------------------------- |
| usage   |               |         | usage message                                 |
| <cmd>   | help          |         | display information about a command           |
| info    |               |         | give information about the running sx-dbtools |
| version |               |         | give the version of the running sx_dbtools    |
| cmd     |               |         | return an interactive bash command            |
| bash    |               |         | alias of command with no arguments            |
| cmd     | command       |         | execute the command and return result         |
| daemon  |               |         | container never giveup and run permanently    |

#### Examples

## Troubleshooting

If you run into difficulties installing or running db-tools, you can [create an issue](https://github.com/startxfr/docker-db-tools/issues/new).

## Built With

- [docker](https://www.docker.com/) - Container plateform
- [couchbase](https://couchbase.com/) - NoSQL Backend
- [mariadb](https://mariadb.org) - SQL Backend

## Contributing

Read the [contributing guide](https://github.com/startxfr/sxapi-core/tree/master/docs/5.Contribute.md) for details on our code of conduct, and the process for submitting pull requests to us.

## Authors

This project is mainly developped by the [startx](https://www.startx.fr) dev team. You can see the complete list of contributors who participated in this project by reading [CONTRIBUTORS.md](https://github.com/startxfr/sxapi-core/tree/master/docs/CONTRIBUTORS.md).

## License

This project is licensed under the Apache License Version 2.0 - see the [LICENSE](https://github.com/startxfr/docker-db-tools/tree/master/LICENSE) file for details
