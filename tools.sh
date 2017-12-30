#!/bin/bash
SXDBT_VERSION="0.0.23"
OS=`cat /etc/os-release | grep "PRETTY_NAME" | sed 's/PRETTY_NAME=//g' | sed 's/["]//g' | awk '{print $1}'`

function displayStartTools {
    echo "==================================" 
    echo "= STARTX db-tools (version $TOOLS_VERSION)"
    echo "= see https://github.com/startxfr/docker-db-tools/"
    echo "= --------------------------------" 
    echo "= version : $TOOLS_VERSION"
    echo "= OS      : $OS"
    echo "= host    : $HOSTNAME"
    if  [  "$1" == "mysql"  ]; then
        echo "= service : $1"
        checkMysqlEnv
        if  [  "$2" == "dump"  ]; then
            echo "= action  : $2"
            echo "==================================" 
            doMysqlDump
        elif  [  "$2" == "create"  ]; then
            echo "= action  : $2"
            echo "==================================" 
            doMysqlCreate
        elif  [  "$2" == "delete"  ]; then
            echo "= action  : $2"
            echo "==================================" 
            doMysqlDelete
        elif  [  "$2" == "reset"  ]; then
            echo "= action  : $2"
            echo "==================================" 
            doMysqlReset
        else
            displayNoAction $1
        fi
    elif  [  "$1" == "couchbase"  ]; then
        echo "= service : $1"
        checkCouchbaseEnv
        if  [  "$2" == "dump"  ]; then
            echo "= action  : $2"
            echo "==================================" 
            doCouchbaseDump
        elif  [  "$2" == "create"  ]; then
            echo "= action  : $2"
            echo "==================================" 
            doCouchbaseCreate
        elif  [  "$2" == "delete"  ]; then
            echo "= action  : $2"
            echo "==================================" 
            doCouchbaseDelete
        elif  [  "$2" == "reset"  ]; then
            echo "= action  : $2"
            echo "==================================" 
            doCouchbaseReset
        else
            displayNoAction $1
        fi
    elif  [  "$1" == "init"  ]; then
        echo "= action  : initialize"
        echo "==================================" 
        echo "waiting 30sec for databases to start"
        sleep 5
        echo "25sec ..."
        sleep 5
        echo "20sec ..."
        sleep 5
        echo "15sec ..."
        sleep 5
        echo "10sec ..."
        sleep 5
        echo "5sec ..."
        sleep 5
        checkMysqlEnv
        if checkMysqlDatabaseExist; then
            echo "Database $MYSQL_DATABASE already exist. Nothing to do"
        else
            echo "Database $MYSQL_DATABASE doesn't exist"
            createMysqlDatabase
            echo "database    : $MYSQL_DATABASE created"
            createMysqlDatabaseUser
            echo "db user     : $MYSQL_DATABASE_USER created"
            loadMysqlDatabaseSchema
            echo "schema file : $MYSQL_DUMP_SCHEMAFILE loaded"
            loadMysqlDatabaseData
            echo "data file   : $MYSQL_DUMP_DATAFILE loaded"
            echo "result      : terminated"
        fi
        checkCouchbaseEnv
        if checkCouchbaseIsNotInitialized; then
            echo "Database $COUCHBASE_HOST is not initialized"
            initializeCouchbase
            echo "Database $COUCHBASE_HOST is initialized"
        fi
        if checkCouchbaseBucketExist; then
            echo "Bucket $COUCHBASE_BUCKET already exist. Nothing to do"
        else
            createCouchbaseBucket
            echo "bucket      : $COUCHBASE_BUCKET created"
            loadCouchbaseBucketData
            echo "data file   : $COUCHBASE_DUMP_DATAFILE loaded"
            echo "result      : terminated"
        fi
        exit 0;
    elif  [  "$1" == "dump"  ]; then
        echo "= action  : dump all databases"
        echo "==================================" 
        checkMysqlEnv
        if checkMysqlDatabaseExist; then
            echo "- Dumping mysql database"
            echo "host        : $MYSQL_HOST"
            echo "database    : $MYSQL_DATABASE"
            echo "destination : $MYSQL_DUMP_DIR"
            dumpMysqlDatabaseSchema
            echo "schema file : $MYSQL_DUMP_SCHEMAFILE saved"
            dumpMysqlDatabaseData
            echo "data file   : $MYSQL_DUMP_DATAFILE saved"
            echo "Mysql database $MYSQL_DATABASE saved"
        else
            echo "Mysql database $MYSQL_DATABASE doesn't exist. Nothing to dump"
        fi
        checkCouchbaseEnv
        if checkCouchbaseIsNotInitialized; then
            echo "Couchbase bucket $COUCHBASE_HOST is not initialized. Nothing to dump"
        
        elif checkCouchbaseBucketExist; then
            echo "- Dumping Couchbase bucket $COUCHBASE_BUCKET"
            echo "host        : $COUCHBASE_HOST"
            echo "bucket      : $COUCHBASE_BUCKET"
            echo "destination : $COUCHBASE_DUMP_DIR"
            dumpCouchbaseBucket
            echo "dump file   : $COUCHBASE_DUMP_DIR saved"
        else
            echo "Couchbase bucket $COUCHBASE_BUCKET doesn't exist. Nothing to dump"
        fi
        echo "Dump terminated"
        exit 0;
    elif  [  "$1" == "debug"  ]; then
        echo "= action  : debug"
        echo "==================================" 
        printenv
        echo "Debug terminated"
        exit 0;
    elif  [  "$1" == "version"  ]; then
        echo "= action  : version"
        echo "= version : $SXDBT_VERSION"
        echo "==================================" 
        echo "version terminated"
        exit 0;
    else 
        displayNoService
    fi
}

function displayNoService { 
    echo "= service : NOT FOUND"
    echo "==================================" 
    echo "You must run 'startx_dbtools <service>' or"
    echo "docker run ≤tool_image> <service> with a service name or a global action"
    echo "Two service name are available :"
    echo "- mysql     : perform actions against the mysql backend"
    echo "- couchbase : perform actions against the couchbase backend"
    echo "Two global actions are available :"
    echo "- init    : initialize mysql and couchbase backends"
    echo "- dump    : dump data from mysql and couchbase backends"
    echo "- debug   : display debug info about environement"
    echo "- version : display the version number of this tools"
    exit 0;
}

function displayNoAction { 
    echo "= action  : NOT FOUND"
    echo "==================================" 
    echo "You must run 'startx_dbtools $1 <action>' with an action name"
    echo "or docker run ≤tool_image>  $1 <service> with an action name"
    echo "Four actions are available for $1 :"
    echo "- dump   : Dump database data into readable volume"
    echo "- create : Create database and load dump from readable volume"
    echo "- delete : Delete the database"
    echo "- reset  : Delete database and re-create it"
    exit 0;
}

function checkMysqlEnv {
    if [ ! -z "$DBM_ENV_MARIADB_VERSION" ]; then
        echo "Use mysql linked container information"
        echo "server version : $DBM_ENV_MARIADB_VERSION"
        if [ -z "$DBM_PORT_3306_TCP_ADDR" ]; then
            echo "Need to expose port 3306 in your mysql container"
            exit 128;
        fi 
        MYSQL_HOST="$DBM_PORT_3306_TCP_ADDR"
        MYSQL_USER="root"
        if [ -z "$DBM_ENV_MYSQL_ROOT_PASSWORD" ]; then
            echo "Need to set MYSQL_ROOT_PASSWORD environment var in your mysql container"
            exit 128;
        fi 
        MYSQL_PASSWORD="$DBM_ENV_MYSQL_ROOT_PASSWORD"
    else
        echo "No mysql linked container labeled 'dbm'"
        if [ -z "$MYSQL_HOST" ]; then
            echo "Need to set MYSQL_HOST"
            exit 128;
        fi 
        if [ -z "$MYSQL_USER" ]; then
            echo "Need to set MYSQL_USER"
            exit 128;
        fi 
        if [ -z "$MYSQL_PASSWORD" ]; then
            echo "Need to set MYSQL_PASSWORD"
            exit 128;
        fi 
    fi 
    if [ -z "$MYSQL_DATABASE" ]; then
        echo "Need to set MYSQL_DATABASE"
        exit 128;
    fi 
    if [ -z "$MYSQL_DUMP_DIR" ]; then
        echo "Need to set MYSQL_DUMP_DIR"
        exit 128;
    fi 
    if [ -z "$MYSQL_DATABASE_USER" ]; then
        echo "Need to set MYSQL_DATABASE_USER"
        exit 128;
    fi 
    if [ -z "$MYSQL_DATABASE_PASSWORD" ]; then
        echo "Need to set MYSQL_DATABASE_PASSWORD"
        exit 128;
    fi 
}

function checkMysqlDatabaseExist {
    RESULT=`mysql -h $MYSQL_HOST -u $MYSQL_USER --password=$MYSQL_PASSWORD --skip-column-names -e "SHOW DATABASES LIKE '$MYSQL_DATABASE'"`
    if [ "$RESULT" == "$MYSQL_DATABASE" ]; then
        return 0; # no error
    else
        return 1; # error code
    fi
}

function createMysqlDatabase {
    mysql -h $MYSQL_HOST -u $MYSQL_USER --password=$MYSQL_PASSWORD \
    -e "CREATE DATABASE $MYSQL_DATABASE DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;"
}

function createMysqlDatabaseUser {
    mysql -h $MYSQL_HOST -u $MYSQL_USER --password=$MYSQL_PASSWORD \
    -e "CREATE USER $MYSQL_DATABASE_USER IDENTIFIED BY '$MYSQL_DATABASE_PASSWORD'; GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_DATABASE_USER' WITH GRANT OPTION;"
}

function deleteMysqlDatabase {
    mysql -h $MYSQL_HOST -u $MYSQL_USER --password=$MYSQL_PASSWORD \
    -D $MYSQL_DATABASE \
    -e "DROP DATABASE $MYSQL_DATABASE;"
}

function deleteMysqlDatabaseUser {
    mysql -h $MYSQL_HOST -u $MYSQL_USER --password=$MYSQL_PASSWORD \
    -e "DROP USER '$MYSQL_DATABASE_USER';"
}

function loadMysqlDatabaseSchema {
    mysql -h $MYSQL_HOST -u $MYSQL_USER --password=$MYSQL_PASSWORD \
    $MYSQL_DATABASE < $MYSQL_DUMP_DIR/$MYSQL_DUMP_SCHEMAFILE
}

function loadMysqlDatabaseData {
    mysql -h $MYSQL_HOST -u $MYSQL_USER --password=$MYSQL_PASSWORD \
    $MYSQL_DATABASE < $MYSQL_DUMP_DIR/$MYSQL_DUMP_DATAFILE
}

function dumpMysqlDatabaseSchema {
    mysqldump --events --lock-all-tables --set-charset --default-character-set=utf8 -d \
    --host $MYSQL_HOST --user $MYSQL_USER -p$MYSQL_PASSWORD \
    $MYSQL_DATABASE > $MYSQL_DUMP_DIR/$MYSQL_DUMP_SCHEMAFILE
}

function dumpMysqlDatabaseData {
    if [ ! -z "$MYSQL_DUMP_ISEXTENDED" ]; then
        if [[ $MYSQL_DUMP_ISEXTENDED == *"true"* ]]; then
            echo "enable mysql extended option"
            mysqldump --events --lock-all-tables --set-charset --default-character-set=utf8 \
            --skip-opt --add-locks --lock-tables --no-create-info --extended-insert \
            --host $MYSQL_HOST --user $MYSQL_USER -p$MYSQL_PASSWORD \
            $MYSQL_DATABASE > $MYSQL_DUMP_DIR/dd.sql
            echo -e "SET names 'utf8';\n$(cat $MYSQL_DUMP_DIR/dd.sql)" > $MYSQL_DUMP_DIR/dd2.sql
            if(/bin/startx_dbtools-process-mysqldump $MYSQL_DUMP_DIR/dd2.sql >  $MYSQL_DUMP_DIR/dd3.sql == 0) then 
                echo "OK mysql extended worked fine. Get a multiple line dump"
                mv $MYSQL_DUMP_DIR/dd3.sql $MYSQL_DUMP_DIR/$MYSQL_DUMP_DATAFILE
            else
                echo "ERROR in mysql extended option. Use single line dump"
                mv $MYSQL_DUMP_DIR/dd2.sql $MYSQL_DUMP_DIR/$MYSQL_DUMP_DATAFILE
            fi
            rm -f $MYSQL_DUMP_DIR/dd*.sql;
        else
            mysqldump --events --lock-all-tables --set-charset --default-character-set=utf8 \
            --skip-opt --add-locks --lock-tables --no-create-info \
            --host $MYSQL_HOST --user $MYSQL_USER -p$MYSQL_PASSWORD \
            $MYSQL_DATABASE > $MYSQL_DUMP_DIR/dd.sql
            echo -e "SET names 'utf8';\n$(cat $MYSQL_DUMP_DIR/dd.sql)" > $MYSQL_DUMP_DIR/$MYSQL_DUMP_DATAFILE
            rm -f $MYSQL_DUMP_DIR/dd.sql;
        fi 
    else
        mysqldump --events --lock-all-tables --set-charset --default-character-set=utf8 \
        --skip-opt --add-locks --lock-tables --no-create-info \
        --host $MYSQL_HOST --user $MYSQL_USER -p$MYSQL_PASSWORD \
        $MYSQL_DATABASE > $MYSQL_DUMP_DIR/dd.sql
        echo -e "SET names 'utf8';\n$(cat $MYSQL_DUMP_DIR/dd.sql)" > $MYSQL_DUMP_DIR/$MYSQL_DUMP_DATAFILE
        rm -f $MYSQL_DUMP_DIR/dd.sql;
    fi 
}

function doMysqlDump { 
    checkMysqlEnv
    echo "Dumping mysql database"
    echo "host        : $MYSQL_HOST"
    echo "database    : $MYSQL_DATABASE"
    echo "destination : $MYSQL_DUMP_DIR"
    dumpMysqlDatabaseSchema
    echo "schema file : $MYSQL_DUMP_SCHEMAFILE saved"
    dumpMysqlDatabaseData
    echo "data file   : $MYSQL_DUMP_DATAFILE saved"
    echo "result      : terminated"
    exit 0;
}

function doMysqlCreate { 
    checkMysqlEnv
    echo "Create mysql database"
    echo "host        : $MYSQL_HOST"
    if checkMysqlDatabaseExist; then
        echo "! Database already exist"
        echo "You must run 'startx_dbtools mysql delete' before this action"
        echo "You can also run 'startx_dbtools mysql reset' to perform delete a create all in one"
        exit 1;
    else
        echo "source dir  : $MYSQL_DUMP_DIR"
        createMysqlDatabase
        echo "database    : $MYSQL_DATABASE created"
        createMysqlDatabaseUser
        echo "db user     : $MYSQL_DATABASE_USER created"
        loadMysqlDatabaseSchema
        echo "schema file : $MYSQL_DUMP_SCHEMAFILE loaded"
        loadMysqlDatabaseData
        echo "data file   : $MYSQL_DUMP_DATAFILE loaded"
        echo "result      : terminated"
        exit 0;
    fi
}

function doMysqlDelete { 
    checkMysqlEnv
    echo "Delete mysql database"
    echo "host        : $MYSQL_HOST"
    if checkMysqlDatabaseExist; then
        deleteMysqlDatabase
        echo "database    : $MYSQL_DATABASE deleted"
        deleteMysqlDatabaseUser
        echo "db user     : $MYSQL_DATABASE_USER deleted"
        echo "result      : terminated"
        exit 0;
    else
        echo "! Database doesn't exist"
        echo "nothing to delete. Action is terminated"
        exit 1;
    fi
}

function doMysqlReset { 
    checkMysqlEnv
    echo "Reset mysql database"
    echo "host        : $MYSQL_HOST"
    if checkMysqlDatabaseExist; then
        echo "source dir  : $MYSQL_DUMP_DIR"
        deleteMysqlDatabase
        echo "database    : $MYSQL_DATABASE deleted"
        deleteMysqlDatabaseUser
        echo "db user     : $MYSQL_DATABASE_USER deleted"
        createMysqlDatabase
        echo "database    : $MYSQL_DATABASE created"
        createMysqlDatabaseUser
        echo "db user     : $MYSQL_DATABASE_USER created"
        loadMysqlDatabaseSchema
        echo "schema file : $MYSQL_DUMP_SCHEMAFILE loaded"
        loadMysqlDatabaseData
        echo "data file   : $MYSQL_DUMP_DATAFILE loaded"
        echo "result      : terminated"
        exit 0;
    else
        echo "source dir  : $MYSQL_DUMP_DIR"
        createMysqlDatabase
        echo "database    : $MYSQL_DATABASE created"
        loadMysqlDatabaseSchema
        echo "schema file : $MYSQL_DUMP_SCHEMAFILE loaded"
        loadMysqlDatabaseData
        echo "data file   : $MYSQL_DUMP_DATAFILE loaded"
        echo "result      : terminated"
        exit 0;
    fi
}

function checkCouchbaseEnv {
    if [ ! -z "$DBC_PORT_8091_TCP_START" ]; then
        echo "Use couchbase linked container information"
        echo "server point : $DBC_PORT_8091_TCP_START"
        if [ -z "$DBC_PORT_8091_TCP_ADDR" ]; then
            echo "Need to expose port 8091 from your couchbase container"
            exit 128;
        fi 
        COUCHBASE_HOST="$DBC_PORT_8091_TCP_ADDR"
        COUCHBASE_PORT="$DBC_PORT_8091_TCP_PORT_START"
    else
        echo "No mysql linked container labeled 'dbc'"
        if [ -z "$COUCHBASE_HOST" ]; then
            echo "Need to set COUCHBASE_HOST"
            exit 128;
        fi 
        if [ -z "$COUCHBASE_PORT" ]; then
            COUCHBASE_PORT=8091
        fi 
    fi
    if [ -z "$COUCHBASE_BUCKET" ]; then
        echo "Need to set COUCHBASE_BUCKET"
        exit 128;
    fi
    if [ -z "$COUCHBASE_USER" ]; then
        echo "Need to set COUCHBASE_USER"
        exit 128;
    else
        if [ -z "$COUCHBASE_PASSWORD" ]; then
            echo "Need to set COUCHBASE_PASSWORD for user $COUCHBASE_USER"
            exit 128;
        fi
    fi 
    if [ -z "$COUCHBASE_DUMP_DIR" ]; then
        echo "Need to set COUCHBASE_DUMP_DIR"
        exit 128;
    fi 
}

function dumpCouchbaseBucket {
        cbexport json \
        -f list \
        -c couchbase://$COUCHBASE_HOST:$COUCHBASE_PORT \
        -o $COUCHBASE_DUMP_DIR/$COUCHBASE_DUMP_DATAFILE \
        -b $COUCHBASE_BUCKET \
        -u $COUCHBASE_USER \
        -p $COUCHBASE_PASSWORD \
        --include-key _id
}

function checkCouchbaseIsNotInitialized {
    RESULT=`couchbase-cli bucket-list -c couchbase://$COUCHBASE_HOST:$COUCHBASE_PORT -u $COUCHBASE_USER -p $COUCHBASE_PASSWORD`
    if [[ $RESULT == *"Cluster is not initialized"* ]]; then
        return 0; # no error
    else
        return 1; # error code
    fi
}

function checkCouchbaseBucketExist {
    RESULT=`couchbase-cli bucket-list -c couchbase://$COUCHBASE_HOST:$COUCHBASE_PORT -u $COUCHBASE_USER -p $COUCHBASE_PASSWORD | grep $COUCHBASE_BUCKET`
    if [ "$RESULT" == "$COUCHBASE_BUCKET" ]; then
        return 0; # no error
    else
        return 1; # error code
    fi
}

function initializeCouchbase {
    couchbase-cli cluster-init \
    -c couchbase://$COUCHBASE_HOST:$COUCHBASE_PORT \
    --cluster-username $COUCHBASE_USER \
    --cluster-password $COUCHBASE_PASSWORD \
    --cluster-ramsize 1000 \
    --cluster-index-ramsize 300 \
    --cluster-name $COUCHBASE_HOST \
    --services data,index,query \
    --index-storage-setting memopt
}

function createCouchbaseBucket {
    couchbase-cli bucket-create \
    -c couchbase://$COUCHBASE_HOST:$COUCHBASE_PORT \
    -u $COUCHBASE_USER \
    -p $COUCHBASE_PASSWORD \
    --bucket $COUCHBASE_BUCKET \
    --bucket-type couchbase \
    --bucket-ramsize 200 \
    --wait
}

function loadCouchbaseBucketData {
        cbimport json \
        -f list \
        -c couchbase://$COUCHBASE_HOST:$COUCHBASE_PORT \
        -d file://$COUCHBASE_DUMP_DIR/$COUCHBASE_DUMP_DATAFILE \
        -b $COUCHBASE_BUCKET \
        -u $COUCHBASE_USER \
        -p $COUCHBASE_PASSWORD \
        --generate-key %_id%
}

function deleteCouchbaseBucket {
    couchbase-cli bucket-delete \
    -c couchbase://$COUCHBASE_HOST:$COUCHBASE_PORT \
    -u $COUCHBASE_USER \
    -p $COUCHBASE_PASSWORD \
    --bucket $COUCHBASE_BUCKET
}

function doCouchbaseDump { 
    checkCouchbaseEnv
    echo "Dumping couchbase database"
    echo "host        : $COUCHBASE_HOST"
    echo "bucket      : $COUCHBASE_BUCKET"
    echo "destination : $COUCHBASE_DUMP_DIR"
    if checkCouchbaseIsNotInitialized; then
        initializeCouchbase
        echo "cluster : $COUCHBASE_HOST initialized"
    fi
    dumpCouchbaseBucket
    echo "dump file   : $COUCHBASE_DUMP_DIR saved"
    echo "result      : terminated"
    exit 0;
}

function doCouchbaseCreate { 
    checkCouchbaseEnv
    echo "Create couchbase database"
    echo "host        : $COUCHBASE_HOST"
    if checkCouchbaseIsNotInitialized; then
        initializeCouchbase
        echo "cluster : $COUCHBASE_HOST initialized"
    fi
    if checkCouchbaseBucketExist; then
        echo "! Bucket already exist"
        echo "You must run 'startx_dbtools couchbase delete' before this action"
        echo "You can also run 'startx_dbtools couchbase reset' to perform delete a create all in one"
        exit 1;
    else
        echo "source dir  : $COUCHBASE_DUMP_DIR"
        createCouchbaseBucket
        echo "bucket      : $COUCHBASE_BUCKET created"
        loadCouchbaseBucketData
        echo "data file   : $COUCHBASE_DUMP_DATAFILE loaded"
        echo "result      : terminated"
        exit 0;
    fi
}

function doCouchbaseDelete { 
    checkCouchbaseEnv
    echo "Delete couchbase database"
    echo "host        : $COUCHBASE_HOST"
    if checkCouchbaseIsNotInitialized; then
        initializeCouchbase
        echo "cluster : $COUCHBASE_HOST initialized"
    fi
    if checkCouchbaseBucketExist; then
        deleteCouchbaseBucket
        echo "bucket      : $COUCHBASE_BUCKET deleted"
        echo "result      : terminated"
        exit 0;
    else
        echo "! Bucket doesn't exist"
        echo "nothing to delete. Action is terminated"
        exit 1;
    fi
}

function doCouchbaseReset { 
    checkCouchbaseEnv
    echo "Reset couchbase database"
    echo "host        : $COUCHBASE_HOST"
    if checkCouchbaseIsNotInitialized; then
        initializeCouchbase
        echo "cluster : $COUCHBASE_HOST initialized"
    fi
    if checkCouchbaseBucketExist; then
        echo "source dir  : $COUCHBASE_DUMP_DIR"
        deleteCouchbaseBucket
        echo "database    : $COUCHBASE_BUCKET deleted"
        createCouchbaseBucket
        echo "database    : $COUCHBASE_BUCKET created"
        loadCouchbaseBucketData
        echo "data file   : $COUCHBASE_DUMP_DATAFILE loaded"
        echo "result      : terminated"
        exit 0;
    else
        echo "source dir  : $COUCHBASE_DUMP_DIR"
        createCouchbaseBucket
        echo "database    : $COUCHBASE_BUCKET created"
        loadCouchbaseBucketData
        echo "data file   : $COUCHBASE_DUMP_DATAFILE loaded"
        echo "result      : terminated"
        exit 0;
    fi
}

displayStartTools $1 $2