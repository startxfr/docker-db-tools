#!/bin/bash


#######################################
# Display small repetitive information in tabulated information block
#######################################
function displayMysqlTabInfoBlock {
    echo "  - mysql version : $DBM_ENV_MARIADB_VERSION"
    echo "  - server : $MYSQL_HOST"
}


function checkMysqlEnv {
    if [ ! -z "$DBM_ENV_MARIADB_VERSION" ]; then
        if [ -z "$DBM_PORT_3306_TCP_ADDR" ]; then
            displayErrorMessage "Need to expose port 3306 in your mysql container"
            exit 128;
        fi 
        MYSQL_HOST="$DBM_PORT_3306_TCP_ADDR"
        if [ -z "$MYSQL_ADMIN" ]; then
            MYSQL_USER="root"
            if [ -z "$DBM_ENV_MYSQL_ROOT_PASSWORD" ]; then
                displayErrorMessage "Need to set MYSQL_ROOT_PASSWORD environment var in your mysql container"
                exit 128;
            fi 
            MYSQL_PASSWORD="$DBM_ENV_MYSQL_ROOT_PASSWORD"
        else
            set -f; IFS=':'; set -- $MYSQL_ADMIN
            MYSQL_USER=$1; 
            MYSQL_PASSWORD=$2; 
            set +f; unset IFS;
            if [ -z "$MYSQL_PASSWORD" ]; then
                displayErrorMessage "Need to set MYSQL_ADMIN with username:password"
                exit 128;
            fi 
        fi 
    else
        displayDebugMessage "No mysql linked container labeled 'dbm'"
        if [ -z "$MYSQL_HOST" ]; then
            displayErrorMessage "Need to set MYSQL_HOST"
            exit 128;
        fi 
        if [ -z "$MYSQL_ADMIN" ]; then
            displayErrorMessage "Need to set MYSQL_ADMIN"
            exit 128;
        else
            set -f; IFS=':'; set -- $MYSQL_ADMIN
            MYSQL_USER=$1; 
            MYSQL_PASSWORD=$2; 
            set +f; unset IFS;
            if [ -z "$MYSQL_PASSWORD" ]; then
                displayErrorMessage "Need to set MYSQL_ADMIN with username:password"
                exit 128;
            fi 
        fi 
        if [ -z "$MYSQL_PASSWORD" ]; then
            displayErrorMessage "Need to set MYSQL_PASSWORD"
            exit 128;
        fi 
    fi 
    if [ -z "$MYSQL_DATABASE" ]; then
        displayErrorMessage "Need to set MYSQL_DATABASE"
        exit 128;
    fi 
    if [ -z "$MYSQL_DUMP_DIR" ]; then
        displayErrorMessage "Need to set MYSQL_DUMP_DIR"
        exit 128;
    fi 
    if [ -z "$MYSQL_USERS" ]; then
        displayErrorMessage "Need to set MYSQL_USERS"
        exit 128;
    fi 
}

function checkMysqlDatabasesExist {
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

function checkMysqlDatabaseExist {
    RESULT=`mysql -h $MYSQL_HOST -u $MYSQL_USER --password=$MYSQL_PASSWORD --skip-column-names -e "SHOW DATABASES LIKE '$1'"`
    if [ "$RESULT" == "$1" ]; then
        return 0; # no error
    else
        return 1; # error code
    fi
}

function createMysqlDatabases {
    if [ ! -z "$MYSQL_DATABASE" ]; then
        for DATABASE in $(echo $MYSQL_DATABASE | tr "," "\n")
        do
            createMysqlDatabase $DATABASE
        done
    fi 
}
function createMysqlDatabase {
    if [ ! -z "$1" ]; then
        echo "  - create database $1"
        runCreateMysqlDatabase $1
    fi 
}
function runCreateMysqlDatabase {
    mysql -h $MYSQL_HOST -u $MYSQL_USER --password=$MYSQL_PASSWORD \
    -e "CREATE DATABASE $1 DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;"
}

function createMysqlUsers {
    if [ ! -z "$MYSQL_USERS" ]; then
        for userInfo in $(echo $MYSQL_USERS | tr "," "\n")
        do
            set -f; IFS=':'; set -- $userInfo
            USER=$1; PWD=$2; set +f; unset IFS
            createMysqlUser $USER $PWD
        done
    fi 
}
function createMysqlUser {
    if [ ! -z "$1" &&  ! -z "$2" ]; then
        runCreateMysqlUser $USER $PWD
    fi 
}
function runCreateMysqlUser {
    USER=$1
    PWD=$2
    DB=""
    export RANDFILE=/tmp/.rnd
    echo "  - create user : $USER"
    if [ -z "$PWD" ]; then
        PWD=$(openssl rand -base64 32 | sha256sum | base64 | head -c 16 ; echo)
        echo "  - with pwd    : [generated]"
        echo "  - password    : $PWD \( \! NOTICE : display only once\)"
    else 
        echo "  - with pwd    : [user given]"
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
            echo "  - grant       : $USER access to $DATABASE"
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








function importMysqlDatabaseAll {
    if [ ! -z "$MYSQL_DATABASE" ]; then
        for DATABASE in $(echo $MYSQL_DATABASE | tr "," "\n")
        do
            importMysqlDatabaseOne $DATABASE
        done
    fi 
}
function importMysqlDatabaseOne {
    importMysqlDatabaseSchema $1
    importMysqlDatabaseData $1
}

function importMysqlDatabasesSchema {
    if [ ! -z "$MYSQL_DATABASE" ]; then
        for DATABASE in $(echo $MYSQL_DATABASE | tr "," "\n")
        do
            importMysqlDatabaseSchema $DATABASE
        done
    fi 
}
function importMysqlDatabaseSchema {
    if [ ! -z "$1" ]; then
        if [[ -r $MYSQL_DUMP_DIR/$1.$MYSQL_DUMP_SCHEMAFILE ]]; then
            echo "  - importing schema $1.$MYSQL_DUMP_SCHEMAFILE > $1"
            runImportMysqlDatabaseSqlDump $1 $MYSQL_DUMP_DIR/$1.$MYSQL_DUMP_SCHEMAFILE
        elif [[ -r $MYSQL_DUMP_DIR/$MYSQL_DUMP_SCHEMAFILE ]]; then
            echo "  - importing schema $MYSQL_DUMP_SCHEMAFILE > $1 LOADED"
            runImportMysqlDatabaseSqlDump $1 $MYSQL_DUMP_DIR/$MYSQL_DUMP_SCHEMAFILE
        fi 
    fi 
}
function runImportMysqlDatabaseSqlDump {
    mysql -h $MYSQL_HOST -u $MYSQL_USER --password=$MYSQL_PASSWORD $1 < $2
}

function importMysqlDatabasesData {
    if [ ! -z "$MYSQL_DATABASE" ]; then
        for DATABASE in $(echo $MYSQL_DATABASE | tr "," "\n")
        do
            importMysqlDatabaseData $DATABASE
        done
    fi 
}
function importMysqlDatabaseData {
    if [ ! -z "$1" ]; then
        if [[ -r $MYSQL_DUMP_DIR/$1.$MYSQL_DUMP_DATAFILE ]]; then
            echo "  - importing data $1.$MYSQL_DUMP_DATAFILE > $1 LOADED"
            runImportMysqlDatabaseSqlDump $1 $MYSQL_DUMP_DIR/$1.$MYSQL_DUMP_DATAFILE
        elif [[ -r $MYSQL_DUMP_DIR/$MYSQL_DUMP_DATAFILE ]]; then
            echo "  - importing data $MYSQL_DUMP_DATAFILE > $1 LOADED"
            runImportMysqlDatabaseSqlDump $1 $MYSQL_DUMP_DIR/$MYSQL_DUMP_DATAFILE
        fi 
    fi 
}


function dumpMysqlDatabaseAll {
    if [ ! -z "$MYSQL_DATABASE" ]; then
        for DATABASE in $(echo $MYSQL_DATABASE | tr "," "\n")
        do
            dumpMysqlDatabaseOne $DATABASE
        done
    fi 
}
function dumpMysqlDatabaseOne {
    echo "  - dump schema $1 > $1.$MYSQL_DUMP_SCHEMAFILE"
    runDumpMysqlDatabaseSchema $1 $MYSQL_DUMP_DIR/$1.$MYSQL_DUMP_SCHEMAFILE
    echo "  - dump data $1 > $1.$MYSQL_DUMP_SCHEMAFILE"
    runDumpMysqlDatabaseData $1 $MYSQL_DUMP_DIR/$1.$MYSQL_DUMP_DATAFILE
}

function dumpMysqlDatabaseSchema {
    if [ ! -z "$MYSQL_DATABASE" ]; then
        for DATABASE in $(echo $MYSQL_DATABASE | tr "," "\n")
        do
            echo "  - dump schema $DATABASE > $DATABASE.$MYSQL_DUMP_SCHEMAFILE"
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
            echo "  - dump data $DATABASE > $DATABASE.$MYSQL_DUMP_SCHEMAFILE"
            runDumpMysqlDatabaseData $DATABASE $MYSQL_DUMP_DIR/$DATABASE.$MYSQL_DUMP_DATAFILE
        done
    fi 
}
function runDumpMysqlDatabaseData {
    if [ ! -z "$MYSQL_DUMP_ISEXTENDED" ]; then
        if [[ $MYSQL_DUMP_ISEXTENDED == *"true"* ]]; then
            displayDebugMessage "enable mysql extended option"
            mysqldump --events --lock-all-tables --set-charset --default-character-set=utf8 \
            --skip-opt --add-locks --lock-tables --no-create-info --extended-insert \
            --host $MYSQL_HOST --user $MYSQL_USER -p$MYSQL_PASSWORD \
            $1 > $MYSQL_DUMP_DIR/dd.sql
            echo -e "SET names 'utf8';\n$(cat $MYSQL_DUMP_DIR/dd.sql)" > $MYSQL_DUMP_DIR/dd2.sql
            if(/bin/sx-dbtools-process-mysqldump $MYSQL_DUMP_DIR/dd2.sql >  $MYSQL_DUMP_DIR/dd3.sql == 0) then 
                displayDebugMessage "OK mysql extended worked fine. Get a multiple line dump"
                mv $MYSQL_DUMP_DIR/dd3.sql $2
            else
                displayErrorMessage "mysql extended option returned error. Use single line dump"
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
    dumpMysqlDatabaseData
    echo "result      : terminated"
    exit 0;
}

function doMysqlCreate { 
    checkMysqlEnv
    echo "=             Create mysql database"
    echo "==================================" 
    echo "host        : $MYSQL_HOST"
    if checkMysqlDatabasesExist; then
        echo "! Database already exist"
        echo "You must run 'sx-dbtools mysql delete' before this action"
        echo "You can also run 'sx-dbtools mysql reset' to perform delete a create all in one"
        exit 1;
    else
        echo "source dir  : $MYSQL_DUMP_DIR"
        createMysqlDatabases
        createMysqlUsers
        importMysqlDatabasesSchema
        echo "schema file : $MYSQL_DUMP_SCHEMAFILE loaded"
        importMysqlDatabasesData
        echo "data file   : $MYSQL_DUMP_DATAFILE loaded"
        echo "result      : terminated"
        exit 0;
    fi
}

function doMysqlCreateUser { 
    checkMysqlEnv
    createMysqlUsers
    exit 0;
}

function doMysqlDelete { 
    checkMysqlEnv
    echo "=             Delete mysql database"
    echo "==================================" 
    echo "host        : $MYSQL_HOST"
    if checkMysqlDatabasesExist; then
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
    if checkMysqlDatabasesExist; then
        echo "source dir  : $MYSQL_DUMP_DIR"
        deleteMysqlDatabase
        deleteMysqlDatabaseUser
        createMysqlDatabases
        createMysqlUsers
        importMysqlDatabasesSchema
        echo "schema file : $MYSQL_DUMP_SCHEMAFILE loaded"
        importMysqlDatabasesData
        echo "data file   : $MYSQL_DUMP_DATAFILE loaded"
        echo "result      : terminated"
        exit 0;
    else
        echo "source dir  : $MYSQL_DUMP_DIR"
        createMysqlDatabases
        importMysqlDatabasesSchema
        echo "schema file : $MYSQL_DUMP_SCHEMAFILE loaded"
        importMysqlDatabasesData
        echo "data file   : $MYSQL_DUMP_DATAFILE loaded"
        echo "result      : terminated"
        exit 0;
    fi
}
