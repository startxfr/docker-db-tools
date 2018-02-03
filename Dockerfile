FROM couchbase:enterprise-5.0.1

RUN apt-get update -y && \
    apt-get dist-upgrade -y && \
    apt-get install -y mariadb-server-5.5 mariadb-client-5.5 tar gzip && \
    apt-get clean

ENV SXDBTOOLS_VERSION="0.1.10" \
    SXDBTOOLS_DEBUG=false \
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
    SUMMARY="Database tools for manipulating couchbase and mariadb container" \
    DESCRIPTION="The s2i-dbtools image, provides any command for creating, import and export \
backup and restore, deleting and recreating both mysql and / or couchbase linked container 

LABEL summary="$SUMMARY" \
      description="$DESCRIPTION" \
      io.k8s.description="$DESCRIPTION" \
      io.k8s.display-name="s2i-dbtools" \
      fr.startx.component="s2i-sx-dbtools" \
      io.openshift.tags="builder,db,mysql,couchbase" \
      io.s2i.scripts-url=image:///usr/libexec/s2i \
      io.openshift.s2i.scripts-url=image:///usr/libexec/s2i \
      io.openshift.s2i.assemble-input-files=image:///usr/libexec/s2i \
      name="startx/s2i-dbtools" \
      version="1" \
      release="1" \
      usage="s2i build https://github.com/youruser/yourapp.git --context-dir=sample/ startx/s2i-dbtools test-dbtools" \
      maintainer="startx.fr <dev@startx.fr>"

COPY ./bin /tmp/sxbin
COPY ./.s2i/bin/* /usr/libexec/s2i/
RUN mv /tmp/sxbin/* /bin/ && \
    rm -rf /tmp/sxbin && \
    mkdir -p $MYSQL_DUMP_DIR && \
    mkdir -p $COUCHBASE_DUMP_DIR && \
    mkdir -p $SXDBTOOLS_BACKUP_DIR && \
    chmod -R ug+x /bin/sx-dbtools* && \
    rm -f /bin/sx-dbtools*.c && \
    adduser couchbase mysql > /dev/null && \
    adduser mysql couchbase > /dev/null  && \
    chgrp -R 0 $SXDBTOOLS_BACKUP_DIR $SXDBTOOLS_BACKUP_DIR  && \
    chmod -R g=u $SXDBTOOLS_BACKUP_DIR $SXDBTOOLS_BACKUP_DIR 

WORKDIR /

USER 1001

VOLUME $SXDBTOOLS_DUMP_DIR
VOLUME $SXDBTOOLS_BACKUP_DIR


ENTRYPOINT ["/bin/sx-dbtools"]
CMD ["usage"]
