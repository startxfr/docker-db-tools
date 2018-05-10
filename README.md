# docker-db-tools ![sxapi](https://img.shields.io/badge/latest-v0.1.22-blue.svg)

SXDbTools is a container for managing data from and to a mysql and/or a couchbase backend. All command work with a couchbase cluser and / or a mysql server the same way.

Features list :
- Dumping multiple buckets or database(s) content
- Importing multiple dump into database(s) or bucket(s)
- Creating bucket and/or database, user(s) + load data into couchbase or mysql
- Deleting and Recreating bucket and/or database, user(s) + load data into couchbase or mysql
- Creating multiple bucket or database user(s)
- Deleting and Recreating multiple bucket or database user(s)
- Creating multiple bucket(s) or database(s)
- Deleting and Recreating multiple bucket(s) or database(s)
- Backup multiple buckets or database(s) content into archives
- Importing archive into buckets or database(s)
- Use volume for persisting data and load data from external source
- Use container linking to discover mysql credentials
- Available as a s2i builder to build openshift pod ready to inject or backup couchbase cluser or mysql server

[![Build Status](https://travis-ci.org/startxfr/docker-db-tools.svg?branch=master)](https://travis-ci.org/startxfr/docker-db-tools) [![docker build](https://img.shields.io/docker/build/startx/db-tools.svg)](https://hub.docker.com/r/startx/db-tools/) [![last commit](https://img.shields.io/github/last-commit/startxfr/docker-db-tools.svg)](https://github.com/startxfr/docker-db-tools) [![licence](https://img.shields.io/github/license/startxfr/docker-db-tools.svg)](https://github.com/startxfr/docker-db-tools) 

## Supported tags and respective Dockerfile links

sx-dbtools is available from [dockerhub registry](https://hub.docker.com/) under the [startx namespace](https://hub.docker.com/r/startx/). You can use image name [startx/db-tools](https://hub.docker.com/r/startx/db-tools/) to access this image. Add a flavour to get the desired version, for example `docker pull startx/db-tools:latest` for the latest version. <br>
Here is a list of the various available versions.

| Docker tag     | branch / tag                                                                | Dockerfile                                                                            | Description
|----------------|-----------------------------------------------------------------------------|---------------------------------------------------------------------------------------|---------------
| `latest`       | [master](https://github.com/startxfr/docker-db-tools/blob/master)           | [Dockerfile](https://github.com/startxfr/docker-db-tools/blob/master/Dockerfile)      | Docker image with debug activated + local sample volume + local application volume + docker-compose test environment
| `testing`      | [testing](https://github.com/startxfr/docker-db-tools/blob/testing)         | [Dockerfile](https://github.com/startxfr/docker-db-tools/blob/testing/Dockerfile)     | Docker image with debug activated + local sample volume + docker-compose test environment
| `stable`       | [docker](https://github.com/startxfr/docker-db-tools/blob/docker)           | [Dockerfile](https://github.com/startxfr/docker-db-tools/blob/docker/Dockerfile)      | Docker image with debug desactivated
| `stable-s2i`   | [s2i](https://github.com/startxfr/docker-db-tools/blob/s2i)                 | [Dockerfile](https://github.com/startxfr/docker-db-tools/blob/s2i/Dockerfile)         | Docker image with s2i config + debug desactivated
| `0.1.22`       | [v0.1.22](https://github.com/startxfr/docker-db-tools/blob/v0.1.22)         | [Dockerfile](https://github.com/startxfr/docker-db-tools/blob/v0.1.22/Dockerfile)     | Latest release version coresponding to a fixed in time stable release (full list available on [tag list](https://hub.docker.com/r/startx/db-tools/tags/))
| `0.1.22-s2i`   | [v0.1.22-s2i](https://github.com/startxfr/docker-db-tools/blob/v0.1.22-s2i) | [Dockerfile](https://github.com/startxfr/docker-db-tools/blob/v0.1.22-s2i/Dockerfile) | Latest release version coresponding to a fixed in time stable release (full list available on [tag list](https://hub.docker.com/r/startx/db-tools/tags/))

## Getting Started

- [Docker user guide](https://github.com/startxfr/docker-db-tools/tree/master/docs/USE_docker.md) if you only have docker installed
- [Docker-compose user guide](https://github.com/startxfr/docker-db-tools/tree/master/docs/USE_compose.md) if you have docker-compose installed
- [Openshift user guide](https://github.com/startxfr/docker-db-tools/tree/master/docs/USE_openshift.md) if you have access to an Openshift cluster or use s2i tools on top of docker

## Linked services

you must tag properly the database service when you link your containers. 

| Link tag  | Description
|-----------|:------------
| dbm       | mysql container running offical `mariadb:5.5` image
| dbc       | couchbase container running offical `couchbase:5.0.1` image

See [docker linked services examples](https://github.com/startxfr/docker-db-tools/tree/master/docs/USE_docker.md#linked-services), [docker-compose linked services examples](https://github.com/startxfr/docker-db-tools/tree/master/docs/USE_compose.md#linked-services) or [openshift linked services examples](https://github.com/startxfr/docker-db-tools/tree/master/docs/USE_openshift.md#linked-services) for copy and paste examples.

## Data volumes

you must use the appropriate data volumes and fill them with appropriate file to get your data
loaded or dumped properly.

| Container volume   | Description
|--------------------|:------------
| `/dump`            | volume containing a `mysql` directory and/or a `couchbase` directory
| `/backup`          | volume containing backup files

See [docker data volumes examples](https://github.com/startxfr/docker-db-tools/tree/master/docs/USE_docker.md#data-volumes), [docker-compose data volumes examples](https://github.com/startxfr/docker-db-tools/tree/master/docs/USE_compose.md#data-volumes) or [openshift data volumes examples](https://github.com/startxfr/docker-db-tools/tree/master/docs/USE_openshift.md#data-volumes) for copy and paste examples.

## Environement variables

Using environement variable you can customize this tools and use it to interact with
various kind of backend infrastructure (container, host, remote, IaaS, DBaaS)

| Variable                 | Default         | Description
|--------------------------|:---------------:|:---------------
| SXCMD                    |                 | If set, container will execute this command instead of the container command (ex: SXCMD="create mysql demo2" for creating the demo2 mysql database)
| SXDBTOOLS_DEBUG          | true            | Activate debugging display
| SXDBTOOLS_BACKUP_DIR     | /backup         | The final destination directory for backup
| SXDBTOOLS_DUMP_DIR       | /dump           | The final destination directory for dump
| SXDBTOOLS_DELAY          |                 | Use this param with a positive integer to delay execution of the command
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

See [docker environement variables examples](https://github.com/startxfr/docker-db-tools/tree/master/docs/USE_docker.md#environement-variables), [docker-compose environement variables examples](https://github.com/startxfr/docker-db-tools/tree/master/docs/USE_compose.md#environement-variables) or [openshift environement variables examples](https://github.com/startxfr/docker-db-tools/tree/master/docs/USE_openshift.md#environement-variables) for copy and paste examples.

## Actions you can perform

### Global Commands

| Command        | database-type   | options  | Description
|----------------|-----------------|----------|---------------
| create         |                 |          | Create all user(s) + database(s) + data for all database type
| create         | mysql/couchbase |          | Create all user(s) + database(s) + data for one database type (mysql or couchbase)
| create         | mysql/couchbase | database | Create one database + data for one database type (mysql or couchbase)
| delete         |                 |          | Delete all user(s) + database(s) + data for all database type
| delete         | mysql/couchbase |          | Delete all user(s) + database(s) + data for one database type (mysql or couchbase)
| delete         | mysql/couchbase | database | Delete one database + data for one database type (mysql or couchbase)
| recreate       |                 |          | Delete and create all user(s) + database(s) + data for all database type
| recreate       | mysql/couchbase |          | Delete and create all user(s) + database(s) + data for one database type (mysql or couchbase)
| recreate       | mysql/couchbase | database | Delete and create one database + data for one database type (mysql or couchbase)

See [docker global commands examples](https://github.com/startxfr/docker-db-tools/tree/master/docs/USE_docker.md#global-commands), [docker-compose global commands examples](https://github.com/startxfr/docker-db-tools/tree/master/docs/USE_compose.md#global-commands) or [openshift global commands examples](https://github.com/startxfr/docker-db-tools/tree/master/docs/USE_openshift.md#global-commands) for copy and paste examples.

### Data Commands

| Command        | database-type   | options  | Description
|----------------|-----------------|----------|---------------
| dump           |                 |          | Dump all database(s) AND all bucket(s) in dump directory
| dump           | mysql/couchbase |          | Dump all database(s) OR all bucket(s) in dump directory
| dump           | mysql/couchbase | database | Dump only one database or bucket in dump directory
| import         |                 |          | import all database(s) AND all bucket(s) from dump directory
| import         | mysql/couchbase |          | import all database(s) OR all bucket(s) from dump directory
| import         | mysql/couchbase | database | import database(s) from dump directory
| create-data    |                 |          | alias of import command

See [docker data commands examples](https://github.com/startxfr/docker-db-tools/tree/master/docs/USE_docker.md#data-commands), [docker-compose data commands examples](https://github.com/startxfr/docker-db-tools/tree/master/docs/USE_compose.md#data-commands) or [openshift data commands examples](https://github.com/startxfr/docker-db-tools/tree/master/docs/USE_openshift.md#data-commands) for copy and paste examples.

### Backup / Restore Commands

| Command        | database-type   | options  | Description
|----------------|-----------------|----------|---------------
| backup         |                 |          | Backup database(s) in backup directory (not implemented)
| backup         | mysql/couchbase |          | Backup all database(s) or all bucket(s) in backup directory (not implemented)
| backup         | mysql/couchbase | database | Backup one database or bucket in backup directory (not implemented)
| restore        | archivename.tgz |          | Restore database(s) in backup directory (not implemented)

See [docker backup/restore commands examples](https://github.com/startxfr/docker-db-tools/tree/master/docs/USE_docker.md#backup--restore-commands), [docker-compose backup/restore commands examples](https://github.com/startxfr/docker-db-tools/tree/master/docs/USE_compose.md#backup--restore-commands) or [openshift backup/restore commands examples](https://github.com/startxfr/docker-db-tools/tree/master/docs/USE_openshift.md#backup--restore-commands) for copy and paste examples.

### Database Commands

| Command        | database-type   | options  | Description
|----------------|-----------------|----------|---------------
| create-db      |                 |          | Create all database(s) for all database type
| create-db      | mysql/couchbase |          | Create all database(s) for one database type (mysql or couchbase)
| create-db      | mysql/couchbase | database | Create one database for one database type (mysql or couchbase)
| delete-db      |                 |          | Delete all database(s) for all database type
| delete-db      | mysql/couchbase |          | Delete all database(s) for one database type (mysql or couchbase)
| delete-db      | mysql/couchbase | database | Delete one database for one database type (mysql or couchbase)
| recreate-db    |                 |          | Delete and create all database(s) for all database type
| recreate-db    | mysql/couchbase |          | Delete and create all database(s) for one database type (mysql or couchbase)
| recreate-db    | mysql/couchbase | database | Delete and create one database for one database type (mysql or couchbase)

See [docker database commands examples](https://github.com/startxfr/docker-db-tools/tree/master/docs/USE_docker.md#database-commands), [docker-compose database commands examples](https://github.com/startxfr/docker-db-tools/tree/master/docs/USE_compose.md#database-commands) or [openshift database commands examples](https://github.com/startxfr/docker-db-tools/tree/master/docs/USE_openshift.md#database-commands) for copy and paste examples.


### User management Commands

| Command        | database-type   | options  | Description
|----------------|-----------------|----------|---------------
| create-user    |                 |          | Create all user(s) for all database type
| create-user    | mysql/couchbase |          | Create all user(s) for one database type (mysql or couchbase)
| create-user    | mysql/couchbase | user     | Create one user for one database type (mysql or couchbase)
| delete-user    |                 |          | Delete all user(s) for all database type
| delete-user    | mysql/couchbase |          | Delete all user(s) for one database type (mysql or couchbase)
| delete-user    | mysql/couchbase | user     | Delete one user for one database type (mysql or couchbase)
| recreate-user  |                 |          | Delete and create all user(s) for all database type
| recreate-user  | mysql/couchbase |          | Delete and create all user(s) for one database type (mysql or couchbase)
| recreate-user  | mysql/couchbase | user     | Delete and create one user for one database type (mysql or couchbase)

See [docker user management commands examples](https://github.com/startxfr/docker-db-tools/tree/master/docs/USE_docker.md#user-management-commands), [docker-compose user management commands examples](https://github.com/startxfr/docker-db-tools/tree/master/docs/USE_compose.md#user-management-commands) or [openshift user management commands examples](https://github.com/startxfr/docker-db-tools/tree/master/docs/USE_openshift.md#user-management-commands) for copy and paste examples.

### sx-dbtools Commands

| Command        | database-type   | options  | Description
|----------------|-----------------|----------|---------------
| usage          |                 |          | usage message
| <cmd>          | help            |          | display information about a command
| info           |                 |          | give information about the running sx-dbtools
| version        |                 |          | give the version of the running sx_dbtools
| cmd            |                 |          | return an interactive bash command
| bash           |                 |          | alias of command with no arguments
| cmd            | command         |          | execute the command and return result
| daemon         |                 |          | container never giveup and run permanently

See [docker sx-dbtools commands examples](https://github.com/startxfr/docker-db-tools/tree/master/docs/USE_docker.md#sx-dbtools-commands), [docker-compose sx-dbtools commands examples](https://github.com/startxfr/docker-db-tools/tree/master/docs/USE_compose.md#sx-dbtools-commands) or [openshift sx-dbtools commands examples](https://github.com/startxfr/docker-db-tools/tree/master/docs/USE_openshift.md#sx-dbtools-commands) for copy and paste examples.

## Troubleshooting

If you run into difficulties installing or running db-tools, you can [create an issue](https://github.com/startxfr/docker-db-tools/issues/new).

## Built With

* [docker](https://www.docker.com/) - Container plateform
* [couchbase](https://couchbase.com/) - NoSQL Backend
* [mariadb](https://mariadb.org) - SQL Backend

## Contributing

Read the [contributing guide](https://github.com/startxfr/sxapi-core/tree/master/docs/5.Contribute.md) for details on our code of conduct, and the process for submitting pull requests to us.

## Authors

This project is mainly developped by the [startx](https://www.startx.fr) dev team. You can see the complete list of contributors who participated in this project by reading [CONTRIBUTORS.md](https://github.com/startxfr/sxapi-core/tree/master/docs/CONTRIBUTORS.md).

## License

This project is licensed under the Apache License Version 2.0 - see the [LICENSE](https://github.com/startxfr/docker-db-tools/tree/master/LICENSE) file for details
