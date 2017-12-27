FROM couchbase:enterprise-5.0.1
RUN apt-get update && \
    apt-get dist-upgrade && \
    apt-get install -y mariadb-server-5.5 mariadb-client-5.5 && \
    apt-get clean
ADD tools.sh /bin/sxv4_api_tools
ADD process-mysqldump /bin/sxv4_api_tools-process-mysqldump
RUN chmod ug+x /bin/sxv4_api_tools
ENTRYPOINT ["/bin/sxv4_api_tools"]