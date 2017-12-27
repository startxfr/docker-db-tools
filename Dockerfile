FROM couchbase:enterprise-5.0.1

RUN apt-get update && \
    apt-get dist-upgrade && \
    apt-get install -y mariadb-server-5.5 mariadb-client-5.5 && \
    apt-get clean
COPY mounts /data
COPY process-mysqldump /bin/sxv4_api_tools-process-mysqldump
COPY tools.sh /bin/sxv4_api_tools
RUN chmod ug+x /bin/sxv4_api_tools

VOLUME /data/couchbase-dump
VOLUME /data/mysql-dump

USER couchbase

ENV TOOLS_VERSION="0.0.9" \
    MYSQL_DUMP_DIR=/data/mysql-dump \
    MYSQL_DUMP_DATAFILE="data.sql" \
    MYSQL_DUMP_SCHEMAFILE="schema.sql" \
    COUCHBASE_DUMP_DIR=/data/couchbase-dump \
    COUCHBASE_DUMP_DATAFILE="data.json" \
    MYSQL_HOST=dbm \
    MYSQL_USER=root \
    MYSQL_PASSWORD=root \
    MYSQL_DATABASE=dev \
    MYSQL_DATABASE_USER=dev \
    MYSQL_DATABASE_PASSWORD=dev \
    MYSQL_DUMP_ISEXTENDED=true \
    COUCHBASE_HOST=dbc \
    COUCHBASE_USER=dev \
    COUCHBASE_PASSWORD=dev \
    COUCHBASE_BUCKET=dev

ENTRYPOINT ["/bin/sxv4_api_tools"]