# docker-db-tools ![sxapi](https://img.shields.io/badge/latest-v0.0.12-blue.svg)

Container for managing data from a mysql and/or a couchbase backend. 
Linked to a mysql and/or a couchbase backend you can easyly create, save and restore 
content from one database or one bucket.

[![Build Status](https://travis-ci.org/startxfr/docker-db-tools.svg?branch=master)](https://travis-ci.org/startxfr/docker-db-tools) [![docker build](https://img.shields.io/docker/build/startx/db-tools.svg)](https://hub.docker.com/r/startx/db-tools/) [![last commit](https://img.shields.io/github/last-commit/startxfr/docker-db-tools.svg)](https://github.com/startxfr/docker-db-tools) [licence](https://img.shields.io/github/license/startxfr/docker-db-tools.svg)](https://github.com/startxfr/docker-db-tools) 

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
docker run -d --link db-mysql:dbm -v ./:/data/mysql:rw startx/db-tools mysql dump
```

Dump a couchbase bucket
```bash
docker run -d --link db-couchbase:dbc -v ./:/data/couchbase:rw startx/db-tools couchbase dump
```

## Connected services

you must tag properly the database service when you link your containers. 

| Link tag  | Description
|-----------|:------------
| dbm       | mysql container running offical mariadb:5.5 image
| dbc       | couchbase container running offical couchbase:couchbase:enterprise-5.0.1 image

Initialize mysql and couchbase linked database
```bash
docker run -d --link db-mysql:dbm --link db-couchbase:dbc startx/db-tools init
```

## Data volumes

you must use the appropriate data volumes and fill them with appropriate file to get your data
loaded or dumped properly.

| Container volume | Description
|------------------|:------------
| /data/mysql      | volume containing a schema.sql file + a data.sql file
| /data/couchbase  | volume containing one data.json file

Dump mysql linked database into local directory
```bash
docker run -d --link db-mysql:dbm -v ./:/data/mysql:rw startx/db-tools mysql dump
```
Dump couchbase linked bucket into local directory
```bash
docker run -d --link db-couchbase:dbc -v ./:/data/couchbase:rw startx/db-tools couchbase dump
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
