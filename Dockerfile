FROM couchbase
RUN apt-get update && \
    apt-get dist-upgrade && \
    apt-get install -y mariadb-server mariadb-client && \
    apt-get clean
ADD tools.sh /bin/sxv4_api_tools
ADD process-mysqldump /bin/sxv4_api_tools-process-mysqldump
RUN chmod ug+x /bin/sxv4_api_tools
ENTRYPOINT ["/bin/sxv4_api_tools"]