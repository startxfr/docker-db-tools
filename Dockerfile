FROM couchbase:enterprise-5.0.1

RUN apt-get update -y && \
    apt-get dist-upgrade -y && \
    apt-get install -y mariadb-server-5.5 mariadb-client-5.5 tar gzip && \
    apt-get clean

ENV SXDBTOOLS_VERSION="0.1.11" \
    SXDBTOOLS_DEBUG=true \
    SXDBTOOLS_BACKUP_DIR=/backup \
    SXDBTOOLS_DUMP_DIR=/dump \
    MYSQL_DUMP_DIR=$SXDBTOOLS_DUMP_DIR/mysql \
    MYSQL_DUMP_DATAFILE="data.sql" \
    MYSQL_DUMP_SCHEMAFILE="schema.sql" \
    MYSQL_DUMP_ISEXTENDED=true \
    MYSQL_HOST=dbm \
    COUCHBASE_DUMP_DIR=$SXDBTOOLS_DUMP_DIR/couchbase \
    COUCHBASE_DUMP_DATAFILE="data.json" \
    COUCHBASE_HOST=dbc \
    SUMMARY="Database tools for manipulating couchbase and mariadb container"

LABEL summary="$SUMMARY" \
      description="$SUMMARY" \
      io.k8s.description="$SUMMARY" \
      io.k8s.display-name="sx-dbtools" \
      fr.startx.component="sx-dbtools" \
      io.openshift.tags="db,mysql,couchbase" \
      name="startx/db-tools" \
      version="1" \
      release="1" \
      maintainer="startx.fr <dev@startx.fr>"

COPY ./bin /tmp/sxbin
RUN mv /tmp/sxbin/* /bin/ && \
    rm -rf /tmp/sxbin && \
    mkdir -p $MYSQL_DUMP_DIR && \
    mkdir -p $COUCHBASE_DUMP_DIR && \
    mkdir -p $SXDBTOOLS_BACKUP_DIR && \
    chmod -R ug+x /bin/sx-dbtools* && \
    rm -f /bin/sx-dbtools*.c && \
    adduser couchbase mysql > /dev/null && \
    adduser mysql couchbase > /dev/null  && \
    chmod -R ugo+rw $SXDBTOOLS_BACKUP_DIR $SXDBTOOLS_BACKUP_DIR 

WORKDIR /

USER couchbase

VOLUME $SXDBTOOLS_DUMP_DIR
VOLUME $SXDBTOOLS_BACKUP_DIR


ENTRYPOINT ["/bin/sx-dbtools"]
CMD ["usage"]
