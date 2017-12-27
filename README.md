# docker-db-tools ![sxapi](https://img.shields.io/badge/latest-v0.0.11-blue.svg)

Container for managing data from a mysql and/or a couchbase backend. 
Linked to a mysql and/or a couchbase backend you can easyly create, save and restore 
content from one database or one bucket.

[![Build Status](https://travis-ci.org/startxfr/docker-db-tools.svg?branch=master)](https://travis-ci.org/startxfr/docker-db-tools) [![docker build](https://img.shields.io/docker/build/startx/db-tools.svg)](https://hub.docker.com/r/startx/db-tools/) [![last commit](https://img.shields.io/github/last-commit/startxfr/docker-db-tools.svg)](https://github.com/startxfr/docker-db-tools) [licence](https://img.shields.io/github/license/startxfr/docker-db-tools.svg)](https://github.com/startxfr/docker-db-tools) 

## Getting Started

- [Docker user guide](https://github.com/startxfr/docker-db-tools/tree/master/docs/USE_docker.md)
- [Docker-compose user guide](https://github.com/startxfr/docker-db-tools/tree/master/docs/USE_compose.md)
- [Openshift user guide](https://github.com/startxfr/docker-db-tools/tree/master/docs/USE_openshift.md)

## Actions you can perform

- mysql
  - create : create user, database and load schema and data into it
  - delete : delete user and database
  - reset  : delete and recreate user and database
  - dump   : save database schema and data
- couchbase
  - create : create bucket and load data into it
  - delete : delete bucket
  - reset  : delete and recreate bucket
  - dump   : save bucket data
- init   : create mysql and couchbase environement
- dump   : save mysql and couchbase environement

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

- dbm : a mysql container running offical mariadb:5.5 image
- dbc : a couchbase container running offical couchbase:couchbase:enterprise-5.0.1 image

```bash
docker run -d \
    --link db-mysql:dbm \
    --link db-couchbase:dbc \
    startx/db-tools \
    init
```

## Data volumes

you must tag properly the database service when you link your containers. 

- /data/mysql : a volume containing one schema.sql file and one data.sql file
- /data/couchbase : a volume containing one data.json file

```bash
docker run -d \
    --link db-mysql:dbm \
    --link db-couchbase:dbc \
    -v ./mounts/mysql:/data/mysql:rw \
    -v ./mounts/couchbase:/data/couchbase:rw \
    startx/db-tools \
    dump
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
