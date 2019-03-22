#!/bin/bash


#######################################
# Display small repetitive information in tabulated information block
#######################################
function displayMysqlTabInfoBlock {
    if [ ! -z "$DBM_ENV_MARIADB_VERSION" ]; then
        echo "  - mysql version : $DBM_ENV_MARIADB_VERSION"
    fi
    echo "  - server : $MYSQL_HOST"
    echo "  - database(s) : $MYSQL_DATABASE"
    if [ `isDebug` == "true" ]; then
        echo "  - mysql admin : $MYSQL_ADMIN"
        echo "  - mysql user(s) : $MYSQL_USERS"
    fi 
}


function checkMysqlEnv {
    displayDebugMessage "base_mysql : checkMysqlEnv()"
    if [ ! -z "$DBM_ENV_MARIADB_VERSION" ]; then
        displayDebugMessage "mysql linked container labeled 'dbm' via docker"
        if [ -z "$DBM_PORT_3306_TCP_ADDR" ]; then
            displayErrorMessage "Need to expose port 3306 in your mysql container"
            exit 128;
        fi 
        MYSQL_HOST="$DBM_PORT_3306_TCP_ADDR"
        displayDebugMessage "mysql host set to $MYSQL_HOST"
        if [ -z "$MYSQL_ADMIN" ]; then
            MYSQL_USER="root"
            displayDebugMessage "mysql admin user set to root"
            if [ -z "$DBM_ENV_MYSQL_ROOT_PASSWORD" ]; then
                displayErrorMessage "Need to set MYSQL_ROOT_PASSWORD environment var in your mysql container"
                exit 128;
            fi 
            displayDebugMessage "mysql admin password set to $MYSQL_PASSWORD"
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
            displayDebugMessage "mysql admin user set to $MYSQL_USER"
            displayDebugMessage "mysql admin password set to $MYSQL_PASSWORD"
        fi 
    elif [ ! -z "$DBM_SERVICE_HOST" ]; then
        displayDebugMessage "mysql linked container labeled 'dbm' via kubernetes"
        if [ -z "$DBM_PORT_3306_TCP_PORT" ]; then
            displayErrorMessage "Need to expose port 3306 in your mysql container"
            exit 128;
        fi 
        MYSQL_HOST="$DBM_SERVICE_HOST"
        displayDebugMessage "mysql host set to $MYSQL_HOST"
        if [ -z "$MYSQL_ADMIN" ]; then
            displayErrorMessage "Need to set MYSQL_ADMIN environment var in your sx-dbtools container"
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
            displayDebugMessage "mysql admin user set to $MYSQL_USER"
            displayDebugMessage "mysql admin password set to $MYSQL_PASSWORD"
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
        displayDebugMessage "mysql admin user set to $MYSQL_USER"
        displayDebugMessage "mysql admin password set to $MYSQL_PASSWORD"
    fi 
    if [ -z "$MYSQL_DATABASE" ]; then
        displayErrorMessage "Need to set MYSQL_DATABASE"
        exit 128;
    fi 
    if [ -z "$MYSQL_DUMP_DIR" ]; then
        displayErrorMessage "Need to set MYSQL_DUMP_DIR"
        exit 128;
    fi 
    mkdir -p $MYSQL_DUMP_DIR
    if [ -z "$MYSQL_USERS" ]; then
        displayErrorMessage "Need to set MYSQL_USERS"
        exit 128;
    fi 
}

function checkMysqlDatabasesExist {
    displayDebugMessage "base_mysql : checkMysqlDatabasesExist()"
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
    displayDebugMessage "base_mysql : checkMysqlDatabaseExist($1)"
    RESULT=`mysql -h $MYSQL_HOST -u $MYSQL_USER --password=$MYSQL_PASSWORD --skip-column-names -e "SHOW DATABASES LIKE '$1'"`
    if [ "$RESULT" == "$1" ]; then
        return 0; # no error
    else
        return 1; # error code
    fi
}

function createMysqlDatabases {
    displayDebugMessage "base_mysql : createMysqlDatabases()"
    if [ ! -z "$MYSQL_DATABASE" ]; then
        for DATABASE in $(echo $MYSQL_DATABASE | tr "," "\n")
        do
            echo "  - create database $DATABASE"
            runCreateMysqlDatabase $DATABASE
        done
    fi 
}
function createMysqlDatabase {
    displayDebugMessage "base_mysql : createMysqlDatabase($1)"
    if [ ! -z "$1" ]; then
        echo "  - create database $1"
        runCreateMysqlDatabase $1
    fi 
}
function runCreateMysqlDatabase {
    displayDebugMessage "base_mysql : runCreateMysqlDatabase($1)"
    mysql -h $MYSQL_HOST -u $MYSQL_USER --password=$MYSQL_PASSWORD \
    -e "CREATE DATABASE $1 DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;"
}

function createMysqlUsers {
    displayDebugMessage "base_mysql : createMysqlUsers()"
    if [ ! -z "$MYSQL_USERS" ]; then
        for userInfo in $(echo $MYSQL_USERS | tr "," "\n")
        do
            set -f; IFS=':'; set -- $userInfo
            USER=$1; PWD=$2; set +f; unset IFS
            createMysqlUser $USER $PWD
        done
    fi 
    if [[ -r $MYSQL_DUMP_DIR/USER ]]; then
        for userInfo in $(cat $MYSQL_DUMP_DIR/USER | tr "," "\n")
        do
            set -f; IFS=':'; set -- $userInfo
            USER=$1; PWD=$2; set +f; unset IFS
            createMysqlUser $USER $PWD
        done
    fi 
}
function createMysqlUser {
    displayDebugMessage "base_mysql : createMysqlUser( $1, $2 )"
    if [[ ! -z "$1" &&  ! -z "$2" ]]; then
        runCreateMysqlUser $USER $PWD
    fi 
}
function runCreateMysqlUser {
    displayDebugMessage "base_mysql : runCreateMysqlUser( $1, $2 )"
    USER=$1
    PWD=$2
    export RANDFILE=/tmp/.rnd
    echo "  - create user : $USER"
    if [ -z "$PWD" ]; then
        PWD=$(openssl rand -base64 32 | sha256sum | base64 | head -c 16 ; echo)
        echo "    - with pwd    : [generated]"
        echo "    - password    : $PWD \( \! NOTICE : display only once\)"
    else 
        echo "    - with pwd    : [user given]"
    fi
    mysql -h $MYSQL_HOST -u $MYSQL_USER --password=$MYSQL_PASSWORD \
    -e "CREATE USER '$USER'@'%' IDENTIFIED BY '$PWD';"
    if [ ! -z "$MYSQL_DATABASE" ]; then
        for DATABASE in $(echo $MYSQL_DATABASE | tr "," "\n")
        do
            echo "    - grant       : $USER access to $DATABASE"
            mysql -h $MYSQL_HOST -u $MYSQL_USER --password=$MYSQL_PASSWORD \
            -e "GRANT ALL PRIVILEGES ON $DATABASE.* TO '$USER' WITH GRANT OPTION;"
        done
    fi 
}

function deleteMysqlDatabases {
    displayDebugMessage "base_mysql : deleteMysqlDatabases()"
    if [ ! -z "$MYSQL_DATABASE" ]; then
        for DATABASE in $(echo $MYSQL_DATABASE | tr "," "\n")
        do
            echo "  - delete database $DATABASE"
            runDeleteMysqlDatabase $DATABASE
        done
    fi 
}
function deleteMysqlDatabase {
    displayDebugMessage "base_mysql : deleteMysqlDatabase($1)"
    if [ ! -z "$1" ]; then
        echo "  - delete database $1"
        runDeleteMysqlDatabase $1
    fi 
}
function runDeleteMysqlDatabase {
    displayDebugMessage "base_mysql : runDeleteMysqlDatabase($1)"
    mysql -h $MYSQL_HOST -u $MYSQL_USER --password=$MYSQL_PASSWORD -D $1 -e "DROP DATABASE $1;"
    displayDebugMessage "delete db : $1 DELETED"
}

function deleteMysqlUsers {
    displayDebugMessage "base_mysql : deleteMysqlUsers()"
    if [ ! -z "$MYSQL_USERS" ]; then
        for userInfo in $(echo $MYSQL_USERS | tr "," "\n")
        do
            set -f; IFS=':'; set -- $userInfo
            USER=$1; PWD=$2; set +f; unset IFS
            echo "  - delete mysql user $1"
            runDeleteMysqlUser $USER
        done
    fi 
    if [[ -r $MYSQL_DUMP_DIR/USER ]]; then
        for userInfo in $(cat $MYSQL_DUMP_DIR/USER | tr "," "\n")
        do
            set -f; IFS=':'; set -- $userInfo
            USER=$1; PWD=$2; set +f; unset IFS
            runDeleteMysqlUser $USER
        done
    fi 
}
function deleteMysqlUser {
    displayDebugMessage "base_mysql : deleteMysqlUser($1)"
    if [ ! -z "$1" ]; then
        echo "  - delete mysql user $1"
        runDeleteMysqlUser $USER
    fi 
}
function runDeleteMysqlUser {
    displayDebugMessage "base_mysql : runDeleteMysqlUser($1)"
    mysql -h $MYSQL_HOST -u $MYSQL_USER --password=$MYSQL_PASSWORD -e "DROP USER '$1'@'%';"
    displayDebugMessage "base mysql : user $1 DELETED"
    mysql -h $MYSQL_HOST -u $MYSQL_USER --password=$MYSQL_PASSWORD -e "FLUSH PRIVILEGES;"
}



function importMysqlDatabases {
    displayDebugMessage "base_mysql : importMysqlDatabases()"
    displayDebugMessage "base mysql : Import databases $MYSQL_DATABASE"
    if [ ! -z "$MYSQL_DATABASE" ]; then
        for DATABASE in $(echo $MYSQL_DATABASE | tr "," "\n")
        do
            importMysqlDatabase $DATABASE
        done
    else
      displayDebugMessage "base mysql : No database \$MYSQL_DATABASE defined"
    fi 
}
function importMysqlDatabase {
    displayDebugMessage "base_mysql : importMysqlDatabase($1)"
    displayDebugMessage "base mysql : Import database $1"
    if [ ! -z "$1" ]; then
        importMysqlDatabaseSchema $1
        importMysqlDatabaseData $1
    else
      displayDebugMessage "base mysql : No database name found"
    fi 
}

function importMysqlDatabasesSchema {
    displayDebugMessage "base_mysql : importMysqlDatabasesSchema()"
    displayDebugMessage "base mysql : Import databases $MYSQL_DATABASE"
    if [ ! -z "$MYSQL_DATABASE" ]; then
        for DATABASE in $(echo $MYSQL_DATABASE | tr "," "\n")
        do
            importMysqlDatabaseSchema $DATABASE
        done
    else
      displayDebugMessage "base mysql : No databases schema import because \$MYSQL_DATABASE not found"
    fi 
}
function importMysqlDatabaseSchema {
    displayDebugMessage "base_mysql : importMysqlDatabaseSchema($1)"
    dt1=`ls $MYSQL_DUMP_DIR/${1}*.$MYSQL_DUMP_SCHEMAFILE 2> /dev/null`
    rtdt1=$?
    displayDebugMessage "base_mysql : Tested existence of $MYSQL_DUMP_DIR/${1}*.$MYSQL_DUMP_SCHEMAFILE files  = $rtdt1"
    dt2=`ls $MYSQL_DUMP_DIR/schema-${1}*.sql 2> /dev/null`
    rtdt2=$?
    displayDebugMessage "base_mysql : Tested existence of $MYSQL_DUMP_DIR/schema-${1}*.sql files  = $rtdt2"
    if [[ "$rtdt1" == "0" ]]; then
        displayDebugMessage "base mysql : importing data from $MYSQL_DUMP_DIR/${1}*.$MYSQL_DUMP_SCHEMAFILE files"
        for SQLFILE in $dt1
        do
            echo "  - import $SQLFILE schema into $DATABASE"
            runDumpMysqlDatabaseSchema $DATABASE $SQLFILE
        done
    elif [[ "$rtdt2" == "0" ]]; then
        displayDebugMessage "base mysql : importing schema from $MYSQL_DUMP_DIR/schema-${1}*.sql files"
        for SQLFILE in $dt2
        do
            echo "  - import $SQLFILE schema into $DATABASE"
            runDumpMysqlDatabaseSchema $DATABASE $SQLFILE
        done
    elif [[ -r $MYSQL_DUMP_DIR/$MYSQL_DUMP_SCHEMAFILE ]]; then
        echo "  - importing schema $MYSQL_DUMP_SCHEMAFILE > $1 LOADED"
        runImportMysqlDatabaseSqlDump $1 $MYSQL_DUMP_DIR/$MYSQL_DUMP_SCHEMAFILE
    else
      displayDebugMessage "base mysql : No database schema import because no $1.$MYSQL_DUMP_SCHEMAFILE, schema-${1}*.sql or $MYSQL_DUMP_DIR/$MYSQL_DUMP_SCHEMAFILE file not found"
    fi
}
function runImportMysqlDatabaseSqlDump {
    displayDebugMessage "base_mysql : runImportMysqlDatabaseSqlDump( $1, $2 )"
    displayDebugMessage "base mysql : Import mysql dump $2 in $1"
    mysql -h $MYSQL_HOST -u $MYSQL_USER --password=$MYSQL_PASSWORD $1 < $2
}

function importMysqlDatabasesData {
    displayDebugMessage "base_mysql : importMysqlDatabasesData()"
    if [ ! -z "$MYSQL_DATABASE" ]; then
        for DATABASE in $(echo $MYSQL_DATABASE | tr "," "\n")
        do
            importMysqlDatabaseData $DATABASE
        done
    else
      displayDebugMessage "base mysql : No databases data import because \$MYSQL_DATABASE not found"
    fi 
}
function importMysqlDatabaseData {
    displayDebugMessage "base_mysql : importMysqlDatabaseData($1)"
    dt1=`ls $MYSQL_DUMP_DIR/${1}*.$MYSQL_DUMP_DATAFILE 2> /dev/null`
    rtdt1=$?
    displayDebugMessage "base_mysql : Tested existence of $MYSQL_DUMP_DIR/${1}*.$MYSQL_DUMP_DATAFILE files  = $rtdt1"
    dt2=`ls $MYSQL_DUMP_DIR/data-${1}*.sql 2> /dev/null`
    rtdt2=$?
    displayDebugMessage "base_mysql : Tested existence of $MYSQL_DUMP_DIR/data-${1}*.sql files  = $rtdt2"
    if [[ "$rtdt1" == "0" ]]; then
        displayDebugMessage "base mysql : importing data from $MYSQL_DUMP_DIR/${1}*.$MYSQL_DUMP_DATAFILE files"
        for SQLFILE in $dt1
        do
            echo "  - import $SQLFILE data into $DATABASE"
            runDumpMysqlDatabaseData $DATABASE $SQLFILE
        done
    elif [[ "$rtdt2" == "0" ]]; then
        displayDebugMessage "base mysql : importing data from $MYSQL_DUMP_DIR/data-${1}*.sql files"
        for SQLFILE in $dt2
        do
            echo "  - import $SQLFILE data into $DATABASE"
            runDumpMysqlDatabaseData $DATABASE $SQLFILE
        done
    elif [[ -r $MYSQL_DUMP_DIR/$MYSQL_DUMP_DATAFILE ]]; then
        echo "  - importing data $MYSQL_DUMP_DATAFILE > $1 LOADED"
        runImportMysqlDatabaseSqlDump $1 $MYSQL_DUMP_DIR/$MYSQL_DUMP_DATAFILE
    else
      displayDebugMessage "base mysql : No database data import because no $1.$MYSQL_DUMP_DATAFILE, data-${1}*.sql or $MYSQL_DUMP_DIR/$MYSQL_DUMP_DATAFILE file not found"
    fi 
}


function dumpMysqlDatabases {
    displayDebugMessage "base_mysql : dumpMysqlDatabases()"
    if [ ! -z "$MYSQL_DATABASE" ]; then
        for DATABASE in $(echo $MYSQL_DATABASE | tr "," "\n")
        do
            dumpMysqlDatabase $DATABASE
        done
    else
      displayDebugMessage "base mysql : No databases dump because \$MYSQL_DATABASE not found"
    fi 
}
function dumpMysqlDatabase {
    displayDebugMessage "base_mysql : dumpMysqlDatabase($1)"
    echo "  - dump schema $1 > $1.$MYSQL_DUMP_SCHEMAFILE"
    runDumpMysqlDatabaseSchema $1 $MYSQL_DUMP_DIR/$1.$MYSQL_DUMP_SCHEMAFILE
    echo "  - dump data $1 > $1.$MYSQL_DUMP_SCHEMAFILE"
    runDumpMysqlDatabaseData $1 $MYSQL_DUMP_DIR/$1.$MYSQL_DUMP_DATAFILE
}

function dumpMysqlDatabasesSchema {
    displayDebugMessage "base_mysql : dumpMysqlDatabasesSchema()"
    if [ ! -z "$MYSQL_DATABASE" ]; then
        for DATABASE in $(echo $MYSQL_DATABASE | tr "," "\n")
        do
            echo "  - dump schema $DATABASE > $DATABASE.$MYSQL_DUMP_SCHEMAFILE"
            runDumpMysqlDatabaseSchema $DATABASE $MYSQL_DUMP_DIR/$DATABASE.$MYSQL_DUMP_SCHEMAFILE
        done
    else
      displayDebugMessage "base mysql : No databases schema dump because \$MYSQL_DATABASE not found"
    fi 
}
function runDumpMysqlDatabaseSchema {
    displayDebugMessage "base_mysql : runDumpMysqlDatabaseSchema( $1, $2 )"
    displayDebugMessage "base mysql : Dumping mysql schema for database $1"
    mysqldump --events --lock-all-tables --set-charset --default-character-set=utf8 -d \
    --host $MYSQL_HOST --user $MYSQL_USER -p$MYSQL_PASSWORD $1 > $2
}

function dumpMysqlDatabasesData {
    displayDebugMessage "base_mysql : dumpMysqlDatabasesData()"
    if [ ! -z "$MYSQL_DATABASE" ]; then
        for DATABASE in $(echo $MYSQL_DATABASE | tr "," "\n")
        do
            echo "  - dump data $DATABASE > $DATABASE.$MYSQL_DUMP_SCHEMAFILE"
            runDumpMysqlDatabaseData $DATABASE $MYSQL_DUMP_DIR/$DATABASE.$MYSQL_DUMP_DATAFILE
        done
    else
      displayDebugMessage "base mysql : No databases data dump because \$MYSQL_DATABASE not found"
    fi 
}
function runDumpMysqlDatabaseData {
    displayDebugMessage "base_mysql : runDumpMysqlDatabaseData( $1, $2 )"
    if [[ ! -z "$MYSQL_DUMP_ISEXTENDED" && $MYSQL_DUMP_ISEXTENDED == *"true"* ]]; then
        displayDebugMessage "base mysql : enable mysql extended option"
        displayDebugMessage "base mysql : Dumping mysql data for database $1 (extended)"
        mysqldump --events --lock-all-tables --set-charset --default-character-set=utf8 \
        --skip-opt --add-locks --lock-tables --no-create-info --extended-insert \
        --host $MYSQL_HOST --user $MYSQL_USER -p$MYSQL_PASSWORD \
        $1 > /tmp/dd.sql
        echo -e "SET names 'utf8';\n$(cat /tmp/dd.sql)" > /tmp/dd2.sql
        if(/bin/sx-dbtools-process-mysqldump /tmp/dd2.sql >  /tmp/dd3.sql == 0) then 
            displayDebugMessage "base mysql : OK mysql extended worked fine. Get a multiple line dump"
            mv /tmp/dd3.sql $2
        else
            displayErrorMessage "base mysql : mysql extended option returned error. Use single line dump"
            mv /tmp/dd2.sql $2
        fi
        rm -f /tmp/dd*.sql;
    else
        displayDebugMessage "base mysql : Dumping mysql data for database $1 (raw)"
        mysqldump --events --lock-all-tables --set-charset --default-character-set=utf8 \
        --skip-opt --add-locks --lock-tables --no-create-info \
        --host $MYSQL_HOST --user $MYSQL_USER -p$MYSQL_PASSWORD \
        $1 > /tmp/dd.sql
        echo -e "SET names 'utf8';\n$(cat /tmp/dd.sql)" > $2
        rm -f /tmp/dd.sql;
    fi 
}
