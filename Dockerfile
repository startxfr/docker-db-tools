FROM couchbase:enterprise-5.0.1

RUN apt-get update -y && \
    apt-get dist-upgrade -y && \
    apt-get install -y mariadb-server-5.5 mariadb-client-5.5 && \
    apt-get clean
COPY mounts /data
COPY process-mysqldump /bin/startx_dbtools-process-mysqldump
COPY tools.sh /bin/startx_dbtools
RUN chmod ug+x /bin/startx_dbtools && \
    adduser couchbase mysql && \
    adduser mysql couchbase  && \
    chmod -R ugo+rw /data

VOLUME /data/couchbase
VOLUME /data/mysql

USER couchbase

ENV TOOLS_VERSION="0.1.0" \
    MYSQL_DUMP_DIR=/data/mysql \
    MYSQL_DUMP_DATAFILE="data.sql" \
    MYSQL_DUMP_SCHEMAFILE="schema.sql" \
    COUCHBASE_DUMP_DIR=/data/couchbase \
    COUCHBASE_DUMP_DATAFILE="data.json" \
    MYSQL_HOST=dbm \
    MYSQL_DATABASE=dev \
    MYSQL_USERS=dev:pwd \
    MYSQL_DUMP_ISEXTENDED=true \
    COUCHBASE_HOST=dbc \
    COUCHBASE_ADMIN=dev:dev \
    COUCHBASE_BUCKET=dev

ENTRYPOINT ["/bin/startx_dbtools"]