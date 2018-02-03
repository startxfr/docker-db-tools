# docker-db-tools ![sxapi](https://img.shields.io/badge/latest-v0.1.1-blue.svg)

Container for managing data from a mysql and/or a couchbase backend. 
Linked to a mysql and/or a couchbase backend you can easyly create, save and restore 
content from one database or one bucket.

[![Build Status](https://travis-ci.org/startxfr/docker-db-tools.svg?branch=master)](https://travis-ci.org/startxfr/docker-db-tools) [![docker build](https://img.shields.io/docker/build/startx/db-tools.svg)](https://hub.docker.com/r/startx/db-tools/) [![last commit](https://img.shields.io/github/last-commit/startxfr/docker-db-tools.svg)](https://github.com/startxfr/docker-db-tools) [![licence](https://img.shields.io/github/license/startxfr/docker-db-tools.svg)](https://github.com/startxfr/docker-db-tools) 

## Getting Started

- [Docker user guide](https://github.com/startxfr/docker-db-tools/tree/master/docs/USE_docker.md)
- [Docker-compose user guide](https://github.com/startxfr/docker-db-tools/tree/master/docs/USE_compose.md)
- [Openshift user guide](https://github.com/startxfr/docker-db-tools/tree/master/docs/USE_openshift.md)

## Actions you can perform

| Service   | Action   | Description
|-----------|:--------:|:---------------
| init      |          | create mysql and couchbase environement
| dump      |          | save mysql and couchbase environement
| mysql     | create   | create user, database and load schema and data into it
| mysql     | delete   | delete user and database
| mysql     | reset    | delete and recreate user and database
| mysql     | dump     | save database schema and data
| couchbase | create   | create bucket and load data into it
| couchbase | delete   | delete bucket
| couchbase | reset    | delete and recreate bucket
| couchbase | dump     | save bucket data

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
