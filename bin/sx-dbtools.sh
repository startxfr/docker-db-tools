#!/bin/bash
SXDBT_VERSION="0.1.0"
OS=`cat /etc/os-release | grep "PRETTY_NAME" | sed 's/PRETTY_NAME=//g' | sed 's/["]//g' | awk '{print $1}'`



function displayDebugMessage {
    if [ ! -z "$SXDBTOOLS_DEBUG" ]; then
        if [[ $SXDBTOOLS_DEBUG == *"true"* ]]; then
            echo "DEBUG: " $@
        fi 
    fi 
}

function displayStartTools {
    echo "==================================" 
    echo "= STARTX db-tools (version $SXDBTOOLS_VERSION)"
    echo "= see https://github.com/startxfr/docker-db-tools/"
    echo "= --------------------------------" 
    echo "= version   : $SXDBTOOLS_VERSION"
    echo "= OS        : $OS"
    echo "= container : $HOSTNAME"
    if  [  "$1" == "mysql"  ]; then
        echo "= service   : $1"
        checkMysqlEnv
        echo "= mysql     : $DBM_ENV_MARIADB_VERSION"
        if  [  "$2" == "dump"  ]; then
            echo "= action  : $2"
            doMysqlDump
        elif  [  "$2" == "create"  ]; then
            echo "= action    : $2"
            doMysqlCreate
        elif  [  "$2" == "create-user"  ]; then
            echo "= action    : $2"
            doMysqlCreateUser
        elif  [  "$2" == "delete"  ]; then
            echo "= action    : $2"
            doMysqlDelete
        elif  [  "$2" == "reset"  ]; then
            echo "= action    : $2"
            doMysqlReset
        else
            displayNoAction $1
        fi
    elif  [  "$1" == "couchbase"  ]; then
        echo "= service   : $1"
        checkCouchbaseEnv
        echo "= couchbase : $COUCHBASE_HOST"
        if  [  "$2" == "dump"  ]; then
            echo "= action    : $2"
            doCouchbaseDump
        elif  [  "$2" == "create"  ]; then
            echo "= action    : $2"
            doCouchbaseCreate
        elif  [  "$2" == "delete"  ]; then
            echo "= action    : $2"
            doCouchbaseDelete
        elif  [  "$2" == "reset"  ]; then
            echo "= action    : $2"
            doCouchbaseReset
        else
            displayNoAction $1
        fi
    elif  [  "$1" == "init"  ]; then
        echo "= mysql     : $DBM_ENV_MARIADB_VERSION"
        echo "= couchbase : $COUCHBASE_HOST"
        echo "= action    : initialize"
        echo "=             initialize all databases"
        echo "==================================" 
        echo "waiting 20sec for databases to start"
        sleep 5
        echo "15sec ..."
        sleep 5
        echo "10sec ..."
        sleep 5
        echo "5sec ..."
        sleep 5
        checkMysqlEnv
        if checkMysqlDatabaseExist; then
            echo "Database $MYSQL_DATABASE is initialized"
        else
            echo "Database $MYSQL_HOST is not initialized"
            createMysqlDatabase
            createMysqlDatabaseUser
            loadMysqlDatabaseSchema
            loadMysqlDatabaseData
            echo "Database $MYSQL_HOST is initialized"
        fi
        checkCouchbaseEnv
        if checkCouchbaseIsNotInitialized; then
            echo "Database $COUCHBASE_HOST is not initialized"
            initializeCouchbase
            echo "Database $COUCHBASE_HOST is initialized"
        fi
        if $(checkCouchbaseBucketExist); then
            echo "Bucket $COUCHBASE_BUCKET already exist"
        else
            createCouchbaseBucket $COUCHBASE_BUCKET
            loadCouchbaseBucketData $COUCHBASE_BUCKET
            echo "result      : terminated"
        fi
        exit 0;
    elif  [  "$1" == "dump"  ]; then
        checkMysqlEnv
        echo "= mysql     : $DBM_ENV_MARIADB_VERSION"
        echo "= couchbase : $COUCHBASE_HOST"
        echo "= action    : dump"
        echo "=             Dump all databases"
        echo "==================================" 
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
        
        elif $(checkCouchbaseBucketExist); then
            echo "- Dumping Couchbase bucket $COUCHBASE_BUCKET"
            echo "host        : $COUCHBASE_HOST"
            echo "bucket      : $COUCHBASE_BUCKET"
            echo "destination : $COUCHBASE_DUMP_DIR"
            dumpCouchbaseBucket
        else
            echo "Couchbase bucket $COUCHBASE_BUCKET doesn't exist. Nothing to dump"
        fi
        echo "Dump terminated"
        exit 0;
    elif  [  "$1" == "debug"  ]; then
        echo "= action    : debug"
        echo "=             Display debug info"
        echo "==================================" 
        printenv
        echo "Debug terminated"
        exit 0;
    elif  [  "$1" == "version"  ]; then
        echo "= action    : version"
        echo "=             display db-tools version"
        echo "= version   : $SXDBT_VERSION"
        echo "==================================" 
        echo "version terminated"
        exit 0;
    elif  [  "$1" == "help"  ]; then
        echo "= action    : help"
        echo "=             display help information"
        echo "==================================" 
        displayHelp
        exit 0;
    else 
        displayNoService
    fi
}

function displayNoService { 
    echo "= service   : NOT FOUND"
    displayHelp
    exit 0;
}
function displayHelp { 
cat <<EOF
You must run 'sx-dbtools <service>' or
docker run ≤tool_image> <service> with a service name or a global action
Two service name are available :
- mysql     : perform actions against the mysql backend
- couchbase : perform actions against the couchbase backend
Five global actions are available :
- init    : initialize mysql and couchbase backends
- dump    : dump data from mysql and couchbase backends
- debug   : display debug info about environement
- version : display the version number of this tools
- help    : display help informations
EOF
}

function displayNoAction { 
cat <<EOF
= action    : NOT FOUND
==================================
You must run 'sx-dbtools $1 <action>' with an action name
or docker run ≤tool_image>  $1 <action> with an action name
Four actions are available for $1 :
- dump   : Dump database data into readable volume
- create : Create database and load dump from readable volume
- delete : Delete the database
- reset  : Delete database and re-create it
EOF
    exit 0;
}

function checkMysqlEnv {
    if [ ! -z "$DBM_ENV_MARIADB_VERSION" ]; then
        if [ -z "$DBM_PORT_3306_TCP_ADDR" ]; then
            echo "Need to expose port 3306 in your mysql container"
            exit 128;
        fi 
        MYSQL_HOST="$DBM_PORT_3306_TCP_ADDR"
        if [ -z "$MYSQL_ADMIN" ]; then
            MYSQL_USER="root"
            if [ -z "$DBM_ENV_MYSQL_ROOT_PASSWORD" ]; then
                echo "Need to set MYSQL_ROOT_PASSWORD environment var in your mysql container"
                echo "or set MYSQL_ADMIN environment var in your db-tools container"
                exit 128;
            fi 
            MYSQL_PASSWORD="$DBM_ENV_MYSQL_ROOT_PASSWORD"
        else
            set -f; IFS=':'; set -- $MYSQL_ADMIN
            MYSQL_USER=$1; 
            MYSQL_PASSWORD=$2; 
            set +f; unset IFS;
            if [ -z "$MYSQL_PASSWORD" ]; then
                echo "Need to set MYSQL_ADMIN with username:password"
                exit 128;
            fi 
        fi 
    else
        echo "No mysql linked container labeled 'dbm'"
        if [ -z "$MYSQL_HOST" ]; then
            echo "Need to set MYSQL_HOST"
            exit 128;
        fi 
        if [ -z "$MYSQL_ADMIN" ]; then
            echo "Need to set MYSQL_ADMIN"
            exit 128;
        else
            set -f; IFS=':'; set -- $MYSQL_ADMIN
            MYSQL_USER=$1; 
            MYSQL_PASSWORD=$2; 
            set +f; unset IFS;
            if [ -z "$MYSQL_PASSWORD" ]; then
                echo "Need to set MYSQL_ADMIN with username:password"
                exit 128;
            fi 
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
    if [ -z "$MYSQL_USERS" ]; then
        echo "Need to set MYSQL_USERS"
        exit 128;
    fi 
}

function checkMysqlDatabaseExist {
    if [ ! -z "$MYSQL_DATABASE" ]; then
        for DATABASE in $(echo $MYSQL_DATABASE | tr "," "\n")
        do
            RESULT=`mysql -h $MYSQL_HOST -u $MYSQL_USER --password=$MYSQL_PASSWORD --skip-column-names -e "SHOW DATABASES LIKE '$DATABASE'"`
            if [ "$RESULT" == "$DATABASE" ]; then
                return 0; # no error
            else
                return 1; # error code
            fi
        done
    fi 
}

function createMysqlDatabase {
    if [ ! -z "$MYSQL_DATABASE" ]; then
        for DATABASE in $(echo $MYSQL_DATABASE | tr "," "\n")
        do
            runCreateMysqlDatabase $DATABASE
        done
    fi 
}
function runCreateMysqlDatabase {
    echo "create db   : $1"
    mysql -h $MYSQL_HOST -u $MYSQL_USER --password=$MYSQL_PASSWORD \
    -e "CREATE DATABASE $1 DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;"
}

function createMysqlDatabaseUser {
    if [ ! -z "$MYSQL_USERS" ]; then
        for userInfo in $(echo $MYSQL_USERS | tr "," "\n")
        do
            set -f; IFS=':'; set -- $userInfo
            USER=$1; PWD=$2; set +f; unset IFS
            runCreateMysqlDatabaseUser $USER $PWD
        done
    fi 
}
function runCreateMysqlDatabaseUser {
    USER=$1
    PWD=$2
    DB=""
    export RANDFILE=/tmp/.rnd
    echo "create user : $USER"
    if [ -z "$PWD" ]; then
        PWD=$(openssl rand -base64 32 | sha256sum | base64 | head -c 16 ; echo)
        echo "with pwd    : [generated]"
        echo "password    : $PWD (! NOTICE : display only once)"
    else 
        echo "with pwd    : [user given]"
    fi
    if [ ! -z "$MYSQL_DATABASE" ]; then
        for DATABASE in $(echo $MYSQL_DATABASE | tr "," "\n")
        do
            DB=$DATABASE
        done
    fi 
    mysql -h $MYSQL_HOST -u $MYSQL_USER --password=$MYSQL_PASSWORD \
    -e "CREATE USER '$USER'@'%' IDENTIFIED BY '$PWD';"
    if [ ! -z "$MYSQL_DATABASE" ]; then
        for DATABASE in $(echo $MYSQL_DATABASE | tr "," "\n")
        do
            echo "grant       : $USER access to $DATABASE"
            mysql -h $MYSQL_HOST -u $MYSQL_USER --password=$MYSQL_PASSWORD \
            -e "GRANT ALL PRIVILEGES ON $DATABASE.* TO '$USER' WITH GRANT OPTION;"
        done
    fi 
}

function deleteMysqlDatabase {
    if [ ! -z "$MYSQL_DATABASE" ]; then
        for DATABASE in $(echo $MYSQL_DATABASE | tr "," "\n")
        do
            runDeleteMysqlDatabase $DATABASE
        done
    fi 
}
function runDeleteMysqlDatabase {
    mysql -h $MYSQL_HOST -u $MYSQL_USER --password=$MYSQL_PASSWORD -D $1 -e "DROP DATABASE $1;"
    echo "delete db   : $1 DELETED"
}

function deleteMysqlDatabaseUser {
    if [ ! -z "$MYSQL_USERS" ]; then
        for userInfo in $(echo $MYSQL_USERS | tr "," "\n")
        do
            set -f; IFS=':'; set -- $userInfo
            USER=$1; PWD=$2; set +f; unset IFS
            runDeleteMysqlDatabaseUser $USER
        done
    fi 
}
function runDeleteMysqlDatabaseUser {
    mysql -h $MYSQL_HOST -u $MYSQL_USER --password=$MYSQL_PASSWORD -e "DROP USER '$1'@'%';"
    echo "del user    : $1 DELETED"
    mysql -h $MYSQL_HOST -u $MYSQL_USER --password=$MYSQL_PASSWORD -e "FLUSH PRIVILEGES;"
}

function loadMysqlDatabaseSchema {
    if [ ! -z "$MYSQL_DATABASE" ]; then
        for DATABASE in $(echo $MYSQL_DATABASE | tr "," "\n")
        do
            if [[ -r $MYSQL_DUMP_DIR/$DATABASE.$MYSQL_DUMP_SCHEMAFILE ]]; then
                runLoadMysqlDatabaseSqlDump $DATABASE $MYSQL_DUMP_DIR/$DATABASE.$MYSQL_DUMP_SCHEMAFILE
            elif [[ -r $MYSQL_DUMP_DIR/$MYSQL_DUMP_SCHEMAFILE ]]; then
                runLoadMysqlDatabaseSqlDump $DATABASE $MYSQL_DUMP_DIR/$MYSQL_DUMP_SCHEMAFILE
            fi 
        done
    fi 
}
function runLoadMysqlDatabaseSqlDump {
    echo "load        : $2 > $1"
    mysql -h $MYSQL_HOST -u $MYSQL_USER --password=$MYSQL_PASSWORD $1 < $2
}

function loadMysqlDatabaseData {
    if [ ! -z "$MYSQL_DATABASE" ]; then
        for DATABASE in $(echo $MYSQL_DATABASE | tr "," "\n")
        do
            if [[ -r $MYSQL_DUMP_DIR/$DATABASE.$MYSQL_DUMP_DATAFILE ]]; then
                runLoadMysqlDatabaseSqlDump $DATABASE $MYSQL_DUMP_DIR/$DATABASE.$MYSQL_DUMP_DATAFILE
            elif [[ -r $MYSQL_DUMP_DIR/$MYSQL_DUMP_DATAFILE ]]; then
                runLoadMysqlDatabaseSqlDump $DATABASE $MYSQL_DUMP_DIR/$MYSQL_DUMP_DATAFILE
            fi 
        done
    fi 
}

function dumpMysqlDatabaseSchema {
    if [ ! -z "$MYSQL_DATABASE" ]; then
        for DATABASE in $(echo $MYSQL_DATABASE | tr "," "\n")
        do
            runDumpMysqlDatabaseSchema $DATABASE $MYSQL_DUMP_DIR/$DATABASE.$MYSQL_DUMP_SCHEMAFILE
        done
    fi 
}
function runDumpMysqlDatabaseSchema {
    mysqldump --events --lock-all-tables --set-charset --default-character-set=utf8 -d \
    --host $MYSQL_HOST --user $MYSQL_USER -p$MYSQL_PASSWORD $1 > $2
}

function dumpMysqlDatabaseData {
    if [ ! -z "$MYSQL_DATABASE" ]; then
        for DATABASE in $(echo $MYSQL_DATABASE | tr "," "\n")
        do
            runDumpMysqlDatabaseData $DATABASE $MYSQL_DUMP_DIR/$DATABASE.$MYSQL_DUMP_DATAFILE
        done
    fi 
}
function runDumpMysqlDatabaseData {
    if [ ! -z "$MYSQL_DUMP_ISEXTENDED" ]; then
        if [[ $MYSQL_DUMP_ISEXTENDED == *"true"* ]]; then
            echo "enable mysql extended option"
            mysqldump --events --lock-all-tables --set-charset --default-character-set=utf8 \
            --skip-opt --add-locks --lock-tables --no-create-info --extended-insert \
            --host $MYSQL_HOST --user $MYSQL_USER -p$MYSQL_PASSWORD \
            $1 > $MYSQL_DUMP_DIR/dd.sql
            echo -e "SET names 'utf8';\n$(cat $MYSQL_DUMP_DIR/dd.sql)" > $MYSQL_DUMP_DIR/dd2.sql
            if(/bin/sx-dbtools-process-mysqldump $MYSQL_DUMP_DIR/dd2.sql >  $MYSQL_DUMP_DIR/dd3.sql == 0) then 
                echo "OK mysql extended worked fine. Get a multiple line dump"
                mv $MYSQL_DUMP_DIR/dd3.sql $2
            else
                echo "ERROR in mysql extended option. Use single line dump"
                mv $MYSQL_DUMP_DIR/dd2.sql $2
            fi
            rm -f $MYSQL_DUMP_DIR/dd*.sql;
        else
            mysqldump --events --lock-all-tables --set-charset --default-character-set=utf8 \
            --skip-opt --add-locks --lock-tables --no-create-info \
            --host $MYSQL_HOST --user $MYSQL_USER -p$MYSQL_PASSWORD \
            $1 > $MYSQL_DUMP_DIR/dd.sql
            echo -e "SET names 'utf8';\n$(cat $MYSQL_DUMP_DIR/dd.sql)" > $2
            rm -f $MYSQL_DUMP_DIR/dd.sql;
        fi 
    else
        mysqldump --events --lock-all-tables --set-charset --default-character-set=utf8 \
        --skip-opt --add-locks --lock-tables --no-create-info \
        --host $MYSQL_HOST --user $MYSQL_USER -p$MYSQL_PASSWORD \
        $1 > $MYSQL_DUMP_DIR/dd.sql
        echo -e "SET names 'utf8';\n$(cat $MYSQL_DUMP_DIR/dd.sql)" > $2
        rm -f $MYSQL_DUMP_DIR/dd.sql;
    fi 
}

function doMysqlDump { 
    checkMysqlEnv
    echo "=             Dumping mysql database"
    echo "==================================" 
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
    echo "=             Create mysql database"
    echo "==================================" 
    echo "host        : $MYSQL_HOST"
    if checkMysqlDatabaseExist; then
        echo "! Database already exist"
        echo "You must run 'sx-dbtools mysql delete' before this action"
        echo "You can also run 'sx-dbtools mysql reset' to perform delete a create all in one"
        exit 1;
    else
        echo "source dir  : $MYSQL_DUMP_DIR"
        createMysqlDatabase
        createMysqlDatabaseUser
        loadMysqlDatabaseSchema
        echo "schema file : $MYSQL_DUMP_SCHEMAFILE loaded"
        loadMysqlDatabaseData
        echo "data file   : $MYSQL_DUMP_DATAFILE loaded"
        echo "result      : terminated"
        exit 0;
    fi
}

function doMysqlCreateUser { 
    checkMysqlEnv
    createMysqlDatabaseUser
    exit 0;
}

function doMysqlDelete { 
    checkMysqlEnv
    echo "=             Delete mysql database"
    echo "==================================" 
    echo "host        : $MYSQL_HOST"
    if checkMysqlDatabaseExist; then
        deleteMysqlDatabase
        deleteMysqlDatabaseUser
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
    echo "=             Reset mysql database"
    echo "==================================" 
    echo "host        : $MYSQL_HOST"
    if checkMysqlDatabaseExist; then
        echo "source dir  : $MYSQL_DUMP_DIR"
        deleteMysqlDatabase
        deleteMysqlDatabaseUser
        createMysqlDatabase
        createMysqlDatabaseUser
        loadMysqlDatabaseSchema
        echo "schema file : $MYSQL_DUMP_SCHEMAFILE loaded"
        loadMysqlDatabaseData
        echo "data file   : $MYSQL_DUMP_DATAFILE loaded"
        echo "result      : terminated"
        exit 0;
    else
        echo "source dir  : $MYSQL_DUMP_DIR"
        createMysqlDatabase
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
    if [ -z "$COUCHBASE_ADMIN" ]; then
        echo "Need to set COUCHBASE_ADMIN"
        exit 128;
    else
        if [ -z "$COUCHBASE_PASSWORD" ]; then
            set -f; IFS=':'; set -- $COUCHBASE_ADMIN
            COUCHBASE_ADMIN=$1; PWD=$2; set +f; unset IFS
            export RANDFILE=/tmp/.rnd
            if [ -z "$PWD" ]; then
                COUCHBASE_GENERATED="true"
                COUCHBASE_PASSWORD=$(openssl rand -base64 32 | sha256sum | base64 | head -c 16 ; echo)
            else 
                COUCHBASE_PASSWORD=$PWD
            fi
        fi
    fi 
    if [ -z "$COUCHBASE_DUMP_DIR" ]; then
        echo "Need to set COUCHBASE_DUMP_DIR"
        exit 128;
    fi 
}

function dumpCouchbaseBucket {
    if [ ! -z "$COUCHBASE_BUCKET" ]; then
        for BUCKET in $(echo $COUCHBASE_BUCKET | tr "," "\n")
        do
            runDumpCouchbaseBucket $BUCKET
        done
    fi 
}
function runDumpCouchbaseBucket {
    if cbexport json \
    -f list \
    -c couchbase://$COUCHBASE_HOST:$COUCHBASE_PORT \
    -o $COUCHBASE_DUMP_DIR/$1.$COUCHBASE_DUMP_DATAFILE \
    -b $1 \
    -u $COUCHBASE_ADMIN \
    -p $COUCHBASE_PASSWORD \
    --include-key _id; then
        echo "dump file   : $COUCHBASE_DUMP_DIR saved"
    else
        echo "dump file   ! Could not dump bucket $1 into $COUCHBASE_DUMP_DIR"
    fi;
}



function checkCouchbaseIsNotInitialized {
    RESULT=`couchbase-cli bucket-list -c couchbase://$COUCHBASE_HOST:$COUCHBASE_PORT -u $COUCHBASE_ADMIN -p $COUCHBASE_PASSWORD`
    if [[ $RESULT == *"Cluster is not initialized"* ]]; then
        return 0; # no error
    else
        return 1; # error code
    fi
}

function checkCouchbaseBucketExist {
    if [ ! -z "$COUCHBASE_BUCKET" ]; then
        for BUCKET in $(echo $COUCHBASE_BUCKET | tr "," "\n")
        do
            echo runCheckCouchbaseBucketExist $BUCKET
            return;
        done
    fi 
}
function runCheckCouchbaseBucketExist {
    RESULT=`couchbase-cli bucket-list -c couchbase://$COUCHBASE_HOST:$COUCHBASE_PORT -u $COUCHBASE_ADMIN -p $COUCHBASE_PASSWORD | grep $1`
    if [ "$RESULT" == "$1" ]; then
        return 0; # no error
    else
        return 1; # error code
    fi
}

function initializeCouchbase {
    couchbase-cli cluster-init \
    -c couchbase://$COUCHBASE_HOST:$COUCHBASE_PORT \
    --cluster-username $COUCHBASE_ADMIN \
    --cluster-password $COUCHBASE_PASSWORD \
    --cluster-ramsize 1000 \
    --cluster-index-ramsize 300 \
    --cluster-name $COUCHBASE_HOST \
    --services data,index,query \
    --index-storage-setting memopt
    echo "cluster     : $COUCHBASE_HOST initialized"
    if [ ! -z "$COUCHBASE_GENERATED" ]; then
        echo "user        : $COUCHBASE_ADMIN created"
        echo "with pwd    : [generated]"
        echo "password    : $COUCHBASE_PASSWORD (! NOTICE : display only once)"
    else 
        echo "user        : $COUCHBASE_ADMIN created"
        echo "with pwd    : [user given]"
    fi
}

function createCouchbaseBucket {
    if [ ! -z "$COUCHBASE_BUCKET" ]; then
        for BUCKET in $(echo $COUCHBASE_BUCKET | tr "," "\n")
        do
            runCreateCouchbaseBucket $BUCKET
        done
    fi 
}
function runCreateCouchbaseBucket {
    if couchbase-cli bucket-create \
    -c couchbase://$COUCHBASE_HOST:$COUCHBASE_PORT \
    -u $COUCHBASE_ADMIN \
    -p $COUCHBASE_PASSWORD \
    --bucket $1 \
    --bucket-type couchbase \
    --bucket-ramsize 200 \
    --wait; then
        echo "bucket      : $1 created"
    else
        echo "bucket      ! Could not create bucket $1"
    fi;
}

function loadCouchbaseBucketData {
    if [ ! -z "$COUCHBASE_BUCKET" ]; then
        for BUCKET in $(echo $COUCHBASE_BUCKET | tr "," "\n")
        do
            runLoadCouchbaseBucketData $BUCKET
        done
    fi 
}
function runLoadCouchbaseBucketData {
    if [[ -r $COUCHBASE_DUMP_DIR/$1.$COUCHBASE_DUMP_DATAFILE ]]; then
        FILE=$1.$COUCHBASE_DUMP_DATAFILE
    elif [[ -r $COUCHBASE_DUMP_DIR/$COUCHBASE_DUMP_DATAFILE ]]; then
        FILE=$COUCHBASE_DUMP_DATAFILE
    fi 
    if cbimport json \
    -f list \
    -c couchbase://$COUCHBASE_HOST:$COUCHBASE_PORT \
    -d file://$COUCHBASE_DUMP_DIR/$FILE \
    -b $1 \
    -u $COUCHBASE_ADMIN \
    -p $COUCHBASE_PASSWORD \
    --generate-key %_id%; then
        echo "data file   : $FILE loaded in bucket $1"
    else
        echo "data file   ! Could not load $FILE in bucket $1"
    fi;
}

function deleteCouchbaseBucket {
    if [ ! -z "$COUCHBASE_BUCKET" ]; then
        for BUCKET in $(echo $COUCHBASE_BUCKET | tr "," "\n")
        do
            runDeleteCouchbaseBucket $BUCKET
        done
    fi 
}
function runDeleteCouchbaseBucket {
    if couchbase-cli bucket-delete \
    -c couchbase://$COUCHBASE_HOST:$COUCHBASE_PORT \
    -u $COUCHBASE_ADMIN \
    -p $COUCHBASE_PASSWORD \
    --bucket $1; then
        echo "bucket      : $1 deleted"
    else
        echo "bucket      ! Could not delete bucket $1"
    fi;
}

function doCouchbaseDump { 
    checkCouchbaseEnv
    echo "=             Dumping couchbase database"
    echo "==================================" 
    echo "host        : $COUCHBASE_HOST"
    echo "bucket      : $COUCHBASE_BUCKET"
    echo "destination : $COUCHBASE_DUMP_DIR"
    if checkCouchbaseIsNotInitialized; then
        initializeCouchbase
        echo "cluster : $COUCHBASE_HOST initialized"
    fi
    dumpCouchbaseBucket
    echo "result      : terminated"
    exit 0;
}

function doCouchbaseCreate { 
    checkCouchbaseEnv
    echo "=             Create couchbase database"
    echo "==================================" 
    echo "host        : $COUCHBASE_HOST"
    if checkCouchbaseIsNotInitialized; then
        initializeCouchbase
        echo "cluster : $COUCHBASE_HOST initialized"
    fi
    if $(checkCouchbaseBucketExist); then
        echo "! Bucket already exist"
        echo "You must run 'sx-dbtools couchbase delete' before this action"
        echo "You can also run 'sx-dbtools couchbase reset' to perform delete a create all in one"
        exit 1;
    else
        echo "source dir  : $COUCHBASE_DUMP_DIR"
        createCouchbaseBucket $COUCHBASE_BUCKET
        loadCouchbaseBucketData $COUCHBASE_BUCKET
        echo "result      : terminated"
        exit 0;
    fi
}

function doCouchbaseDelete { 
    checkCouchbaseEnv
    echo "=             Delete couchbase database"
    echo "==================================" 
    echo "host        : $COUCHBASE_HOST"
    if checkCouchbaseIsNotInitialized; then
        initializeCouchbase
        echo "cluster : $COUCHBASE_HOST initialized"
    fi
    if $(checkCouchbaseBucketExist); then
        deleteCouchbaseBucket $COUCHBASE_BUCKET
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
    echo "=             Reset couchbase database"
    echo "==================================" 
    echo "host        : $COUCHBASE_HOST"
    if checkCouchbaseIsNotInitialized; then
        initializeCouchbase
        echo "cluster : $COUCHBASE_HOST initialized"
    fi
    if $(checkCouchbaseBucketExist); then
        echo "source dir  : $COUCHBASE_DUMP_DIR"
        deleteCouchbaseBucket $COUCHBASE_BUCKET
        createCouchbaseBucket $COUCHBASE_BUCKET
        loadCouchbaseBucketData $COUCHBASE_BUCKET
        echo "result      : terminated"
        exit 0;
    else
        echo "source dir  : $COUCHBASE_DUMP_DIR"
        createCouchbaseBucket $COUCHBASE_BUCKET
        loadCouchbaseBucketData $COUCHBASE_BUCKET
        echo "result      : terminated"
        exit 0;
    fi
}

displayStartTools $1 $2