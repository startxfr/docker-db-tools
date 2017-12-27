FROM couchbase:enterprise-5.0.1
RUN apt-get update && \
    apt-get dist-upgrade && \
    apt-get install -y mariadb-server-5.5 mariadb-client-5.5 && \
    apt-get clean
COPY tools.sh /bin/sxv4_api_tools
COPY process-mysqldump /bin/sxv4_api_tools-process-mysqldump
COPY mounts /data
RUN chmod ug+x /bin/sxv4_api_tools
VOLUME /data/couchbase-dump
VOLUME /data/mysql-dump
ENTRYPOINT ["/bin/sxv4_api_tools"]