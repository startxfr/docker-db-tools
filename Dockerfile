FROM couchbase:enterprise-5.0.1

RUN apt-get update -y && \
    apt-get dist-upgrade -y && \
    apt-get install -y mariadb-server-5.5 mariadb-client-5.5 && \
    apt-get clean
COPY process-mysqldump /bin/sx-dbtools-process-mysqldump
COPY tools.sh /bin/sx-dbtools
RUN mkdir -p /dump/mysql && \
    mkdir -p /dump/couchbase && \
    mkdir -p /backup && \
    chmod ug+x /bin/sx-dbtools && \
    adduser couchbase mysql && \
    adduser mysql couchbase  && \
    chmod -R ugo+rw /dump /backup

VOLUME /dump
VOLUME /backup

USER couchbase

ENV SXDBTOOLS_VERSION="0.1.0" \
    SXDBTOOLS_DEBUG=true \
    MYSQL_DUMP_DIR=/dump/mysql \
    MYSQL_DUMP_DATAFILE="data.sql" \
    MYSQL_DUMP_SCHEMAFILE="schema.sql" \
    MYSQL_DUMP_ISEXTENDED=true \
    MYSQL_HOST=dbm \
    MYSQL_DATABASE=dev \
    MYSQL_USERS=dev:pwd \
    COUCHBASE_DUMP_DIR=/dump/couchbase \
    COUCHBASE_DUMP_DATAFILE="data.json" \
    COUCHBASE_HOST=dbc \
    COUCHBASE_ADMIN=dev:dev \
    COUCHBASE_BUCKET=dev

#ONBUILD COPY data /data

ENTRYPOINT ["/bin/sx-dbtools"]