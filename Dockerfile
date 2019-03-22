FROM couchbase:enterprise-5.0.1

MAINTAINER Startx <dev@startx.fr>

ENV SXDBTOOLS_VERSION="0.1.24" \
    SXDBTOOLS_BACKUP_DIR=/backup \
    SXDBTOOLS_DUMP_DIR=/dump \
    SXDBTOOLS_DEBUG=false \
    MYSQL_DUMP_DIR=/dump/mysql \
    MYSQL_DUMP_DATAFILE="data.sql" \
    MYSQL_DUMP_SCHEMAFILE="schema.sql" \
    MYSQL_DUMP_ISEXTENDED=true \
    MYSQL_HOST=dbm \
    COUCHBASE_DUMP_DIR=/dump/couchbase \
    COUCHBASE_DUMP_DATAFILE="data.json" \
    COUCHBASE_HOST=dbc \
    SUMMARY="Database tools for manipulating couchbase and mariadb container" \
    DESCRIPTION="The s2i-dbtools image, provides any command for creating, import and export \
backup and restore, deleting and recreating both mysql and / or couchbase linked container"

LABEL name="startx/db-tools" \
      summary="$SUMMARY" \
      description="$SUMMARY" \
      version="$SXDBTOOLS_VERSION" \
      release="1" \
      maintainer="Startx <dev@startx.fr>" \
      usage="s2i build https://github.com/startxfr/docker-db-tools-example.git startx/sx-dbtools test-dbtools" \
      io.k8s.description="$SUMMARY" \
      io.k8s.display-name="sx-dbtools" \
      io.openshift.tags="builder,db,mysql,couchbase" \
      io.openshift.wants="mysql,couchbase" \
      io.openshift.non-scalable="true" \
      io.openshift.min-memory="500Mi" \
      io.openshift.min-cpu="500m" \
      io.openshift.s2i.destination="/tmp" \
      io.openshift.s2i.scripts-url=image:///usr/local/s2i \
      io.s2i.scripts-url=image:///usr/local/s2i \
      fr.startx.component="sx-dbtools"

COPY ./.s2i/bin/ /usr/local/s2i
COPY ./bin /tmp/sxbin
RUN apt-get update -y && \
    apt-get dist-upgrade -y && \
    apt-get install -y mariadb-server-5.5 mariadb-client-5.5 tar gzip && \
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
    chgrp -R 0 $SXDBTOOLS_BACKUP_DIR $SXDBTOOLS_BACKUP_DIR /tmp && \
    chmod -R g=u $SXDBTOOLS_BACKUP_DIR $SXDBTOOLS_BACKUP_DIR /tmp

WORKDIR /tmp

USER 1001

VOLUME $SXDBTOOLS_DUMP_DIR
VOLUME $SXDBTOOLS_BACKUP_DIR

ENTRYPOINT ["/bin/sx-dbtools"]
CMD ["welcome"]