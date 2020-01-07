FROM couchbase:enterprise-5.5.2

ENV SXDBTOOLS_VERSION="0.1.39" \
    SXDBTOOLS_BACKUP_DIR=/backup \
    SXDBTOOLS_DUMP_DIR=/dump \
    SXDBTOOLS_DEBUG=true \
    MYSQL_DUMP_DIR=/dump/mysql \
    MYSQL_DUMP_DATAFILE="data.sql" \
    MYSQL_DUMP_SCHEMAFILE="schema.sql" \
    MYSQL_DUMP_ISEXTENDED=true \
    MYSQL_HOST=dbm \
    COUCHBASE_DUMP_DIR=/dump/couchbase \
    COUCHBASE_DUMP_DATAFILE="data.json" \
    COUCHBASE_HOST=dbc \
    SUMMARY="Database tools for manipulating couchbase and mariadb container"

LABEL name="startx/db-tools" \
    summary="$SUMMARY" \
    description="$SUMMARY" \
    version="$SXDBTOOLS_VERSION" \
    release="1" \
    maintainer="Startx <dev@startx.fr>" \
    io.k8s.description="$SUMMARY" \
    io.k8s.display-name="sx-dbtools" \
    io.openshift.tags="db,mysql,couchbase" \
    io.openshift.wants="mysql,couchbase" \
    io.openshift.non-scalable="true" \
    io.openshift.min-memory="500Mi" \
    io.openshift.min-cpu="500m" \
    io.openshift.s2i.destination="/tmp" \
    fr.startx.component="sx-dbtools"

COPY ./bin /tmp/sxbin
RUN apt-get update -y && \
    apt-get dist-upgrade -y && \
    apt-get install -y mariadb-server-10.0 mariadb-client-10.0 tar gzip && \
    apt-get clean && \
    mv /tmp/sxbin/* /bin/ && \
    rm -rf /tmp/sxbin && \
    mkdir -p $MYSQL_DUMP_DIR && \
    mkdir -p $COUCHBASE_DUMP_DIR && \
    mkdir -p $SXDBTOOLS_BACKUP_DIR && \
    chmod -R ug+x /bin/sx-dbtools* && \
    rm -f /bin/sx-dbtools*.c && \
    adduser couchbase mysql > /dev/null && \
    adduser mysql couchbase > /dev/null  && \
    chmod -R ugo+rw $SXDBTOOLS_BACKUP_DIR $SXDBTOOLS_BACKUP_DIR 

WORKDIR /tmp

USER 1001

VOLUME $SXDBTOOLS_DUMP_DIR
VOLUME $SXDBTOOLS_BACKUP_DIR

ENTRYPOINT ["/bin/sx-dbtools"]
CMD ["welcome"]