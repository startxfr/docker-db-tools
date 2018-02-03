# docker-db-tools ![sxapi](https://img.shields.io/badge/latest-v0.1.9-blue.svg)

Container for managing data from a mysql and/or a couchbase backend. 
Linked to a mysql and/or a couchbase backend you can easyly create, save and restore 
content from one database or one bucket.

[![Build Status](https://travis-ci.org/startxfr/docker-db-tools.svg?branch=master)](https://travis-ci.org/startxfr/docker-db-tools) [![docker build](https://img.shields.io/docker/build/startx/db-tools.svg)](https://hub.docker.com/r/startx/db-tools/) [![last commit](https://img.shields.io/github/last-commit/startxfr/docker-db-tools.svg)](https://github.com/startxfr/docker-db-tools) [![licence](https://img.shields.io/github/license/startxfr/docker-db-tools.svg)](https://github.com/startxfr/docker-db-tools) 

## Getting Started

- [Docker user guide](https://github.com/startxfr/docker-db-tools/tree/master/docs/USE_docker.md)
- [Docker-compose user guide](https://github.com/startxfr/docker-db-tools/tree/master/docs/USE_compose.md)
- [Openshift user guide](https://github.com/startxfr/docker-db-tools/tree/master/docs/USE_openshift.md)

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

#### Examples

##### Initialize full stack (mysql + couchbase user, database and data)
```bash
docker run -d \
--link db-mysql:dbm \                       # Linked mysql service
--link db-couchbase:dbc \                   # Linked couchbase service
-v ./mysql-data:/dump/mysql:rw \            # mounted volume with *schema.sql and *data.sql files
-v ./couchbase-data:/dump/couchbase:rw \    # mounted volume with *data.json files
-e MYSQL_DATABASE=demo,demo2,demo3 \        # List of mysql database to manipulate
-e MYSQL_ADMIN=root:rootPassword \          # mysql administrator username and password
-e MYSQL_USERS=demo:pwd,user3:pwd3,test \   # List of mysql user (password optional) to manipulate
-e COUCHBASE_ADMIN=demo:password \          # couchbase administrator username and password
-e COUCHBASE_BUCKET=demo,demo2 \            # List of couchbase bucket to manipulate
-e COUCHBASE_USERS=demo1:password1,demo2 \  # List of couchbase user (password optional) to manipulate
startx/db-tools                             # sx-dbtools docker image 
create                                      # sx-dbtools command
```

##### Recreate full stack (mysql + couchbase user, database and data)
```bash
docker run -d \
--link db-mysql:dbm \                       # Linked mysql service
--link db-couchbase:dbc \                   # Linked couchbase service
-v ./mysql-data:/dump/mysql:rw \            # mounted volume with *schema.sql and *data.sql files
-v ./couchbase-data:/dump/couchbase:rw \    # mounted volume with *data.json files
-e MYSQL_DATABASE=demo,demo2,demo3 \        # List of mysql database to manipulate
-e MYSQL_ADMIN=root:rootPassword \          # mysql administrator username and password
-e MYSQL_USERS=demo:pwd,user3:pwd3,test \   # List of mysql user (password optional) to manipulate
-e COUCHBASE_ADMIN=demo:password \          # couchbase administrator username and password
-e COUCHBASE_BUCKET=demo,demo2 \            # List of couchbase bucket to manipulate
-e COUCHBASE_USERS=demo1:password1,demo2 \  # List of couchbase user (password optional) to manipulate
startx/db-tools                             # sx-dbtools docker image 
recreate                                    # sx-dbtools command
```

##### create one mysql database + data (if available)
```bash
docker run -d \
--link db-mysql:dbm \                       # Linked mysql service
-v ./mysql-data:/dump/mysql:rw \            # mounted volume with *schema.sql and *data.sql files
-e MYSQL_DATABASE=demo,demo2,demo3 \        # List of mysql database to manipulate
-e MYSQL_ADMIN=root:rootPassword \          # mysql administrator username and password
-e MYSQL_USERS=demo:pwd,user3:pwd3,test \   # List of mysql user (password optional) to manipulate
startx/db-tools                             # sx-dbtools docker image 
create mysql demo2                          # sx-dbtools command
```

##### Delete all couchbase bucket(s) and user(s)
```bash
docker run -d \
--link db-couchbase:dbc \                   # Linked couchbase service
-e COUCHBASE_ADMIN=demo:password \          # couchbase administrator username and password
-e COUCHBASE_BUCKET=demo,demo2 \            # List of couchbase bucket to manipulate
-e COUCHBASE_USERS=demo1:password1,demo2 \  # List of couchbase user (password optional) to manipulate
startx/db-tools                             # sx-dbtools docker image 
delete couchbase                            # sx-dbtools command
```


### Data Commands

| Command        | database-type   | options  | Description
|----------------|-----------------|----------|---------------
| dump           |                 |          | Dump database(s) in dump directory
| import         |                 |          | import database(s) from dump directory
| create-data    |                 |          | alias of import command

#### Examples

##### Dump all mysql and couchbase database(s)
```bash
docker run -d \
--link db-mysql:dbm \                       # Linked mysql service
--link db-couchbase:dbc \                   # Linked couchbase service
-v ./mysql-data:/dump/mysql:rw \            # mounted volume with *schema.sql and *data.sql files
-v ./couchbase-data:/dump/couchbase:rw \    # mounted volume with *data.json files
-e MYSQL_DATABASE=demo,demo2,demo3 \        # List of mysql database to manipulate
-e MYSQL_ADMIN=root:rootPassword \          # mysql administrator username and password
-e COUCHBASE_ADMIN=demo:password \          # couchbase administrator username and password
-e COUCHBASE_BUCKET=demo,demo2 \            # List of couchbase bucket to manipulate
startx/db-tools                             # sx-dbtools docker image 
dump                                        # sx-dbtools command
```

##### Dump all mysql database(s)
```bash
docker run -d \
--link db-mysql:dbm \                       # Linked mysql service
-v ./mysql-data:/dump/mysql:rw \            # mounted volume with *schema.sql and *data.sql files
-e MYSQL_DATABASE=demo,demo2,demo3 \        # List of mysql database to manipulate
-e MYSQL_ADMIN=root:rootPassword \          # mysql administrator username and password
startx/db-tools                             # sx-dbtools docker image 
dump mysql                                  # sx-dbtools command
```

##### Dump only one couchbase bucket
```bash
docker run -d \
--link db-couchbase:dbc \                   # Linked couchbase service
-v ./couchbase-data:/dump/couchbase:rw \    # mounted volume with *data.json files
-e COUCHBASE_ADMIN=demo:password \          # couchbase administrator username and password
-e COUCHBASE_BUCKET=demo,demo2 \            # List of couchbase bucket to manipulate
startx/db-tools                             # sx-dbtools docker image 
dump couchbase demo                         # sx-dbtools command
```

##### Import one mysql database
```bash
docker run -d \
--link db-mysql:dbm \                       # Linked mysql service
-v ./mysql-data:/dump/mysql:rw \            # mounted volume with *schema.sql and *data.sql files
-e MYSQL_DATABASE=demo,demo2,demo3 \        # List of mysql database to manipulate
-e MYSQL_ADMIN=root:rootPassword \          # mysql administrator username and password
startx/db-tools                             # sx-dbtools docker image 
import mysql demo2                          # sx-dbtools command
```


### Backup / Restore Commands

| Command        | database-type   | options  | Description
|----------------|-----------------|----------|---------------
| backup         |                 |          | Backup database(s) in backup directory (not implemented)
| restore        |                 |          | Restore database(s) in backup directory (not implemented)


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


### sx-dbtools Commands

| Command        | database-type   | options  | Description
|----------------|-----------------|----------|---------------
| usage          |                 |          | usage message
| <cmd>          | help            |          | display information about a command
| info           |                 |          | give information about the running sx-dbtools
| version        |                 |          | give the version of the running sx_dbtools


Initialize mysql and couchbase backend
```bash
docker run -d --link db-mysql:dbm --link db-couchbase:dbc startx/db-tools init
```

Initialize only a mysql backend
```bash
docker run -d --link db-mysql:dbm startx/db-tools mysql reset
```

Initialize only a couchbase backend
```bash
docker run -d --link db-couchbase:dbc startx/db-tools couchbase reset
```

Dump a mysql database
```bash
docker run -d --link db-mysql:dbm -v ./:/dump/mysql:rw startx/db-tools mysql dump
```

Dump a couchbase bucket
```bash
docker run -d --link db-couchbase:dbc -v ./:/dump/couchbase:rw startx/db-tools couchbase dump
```

## Connected services

you must tag properly the database service when you link your containers. 

| Link tag  | Description
|-----------|:------------
| dbm       | mysql container running offical `mariadb:5.5` image
| dbc       | couchbase container running offical `couchbase:couchbase:enterprise-5.0.1` image

Initialize mysql and couchbase linked database
```bash
docker run -d --link db-mysql:dbm --link db-couchbase:dbc startx/db-tools init
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
docker run -d --link db-mysql:dbm -v ./:/dump/mysql:rw startx/db-tools mysql dump
```
Dump couchbase linked bucket into local directory
```bash
docker run -d --link db-couchbase:dbc -v ./:/dump/couchbase:rw startx/db-tools couchbase dump
```
Dump couchbase and mysql into local directory
```bash
docker run -d \
--link db-couchbase:dbc -v ./:/dump/couchbase:rw \
--link db-mysql:dbm -v ./:/dump/mysql:rw \
startx/db-tools \
couchbase dump
```
Backup couchbase and mysql into local directory
```bash
docker run -d \
--link db-couchbase:dbc \
--link db-mysql:dbm \
-v ./:/backup:rw \
startx/db-tools \
backup
```

## Environement variables

Using environement variable you can customize this tools and use it to interact with
various kind of backend infrastructure (container, host, remote, IaaS, DBaaS)

| Variable                 | Default         | Description
|--------------------------|:---------------:|:---------------
| MYSQL_DUMP_DIR           | /dump/mysql     | Directory used for save and restore mysql dump (container internal path)
| MYSQL_DUMP_DATAFILE      | data.sql        | Filename of the default sql data dump file 
| MYSQL_DUMP_SCHEMAFILE    | schema.sql      | Filename of the default sql schema dump file
| MYSQL_DUMP_ISEXTENDED    | true            | Enable smart extended dump for fast load, readibility and versioning
| MYSQL_HOST               | dbm             | Hostname of the mysql database. Could use whatever public IP or DSN.
| MYSQL_ADMIN              | [linked user]   | Mysql admin user and password (ex: user:password). Default will use root and MYSQL_ROOT_PASSWORD found into the linked container
| MYSQL_DATABASE           | dev             | Mysql database name to use or create
| MYSQL_USERS              | dev             | Mysql list of users to the database "," is separator between users and ":" between user and his password. ex : user:password,user2:user2Password,user3,user4
| COUCHBASE_DUMP_DIR       | /dump/couchbase | Directory used for save and restore couchbase dump (container internal path)
| COUCHBASE_DUMP_DATAFILE  | data.json       | Filename of the json data dump file
| COUCHBASE_HOST           | dbc             | Hostname of the couchbase database. Could use whatever public IP or DSN.
| COUCHBASE_ADMIN          | dev             | Couchbase admin user and password (ex: user:password)
| COUCHBASE_PASSWORD       | dev             | Password for the couchbase admin user
| COUCHBASE_BUCKET         | dev             | Couchbase bucket name to use or create

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
    --env COUCHBASE_ADMIN=cbAdmin \
    --env COUCHBASE_PASSWORD=cbAdmin123 \
    --env COUCHBASE_BUCKET=demo \
    startx/db-tools couchbase create
```

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
