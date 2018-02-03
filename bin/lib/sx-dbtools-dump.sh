#!/bin/bash

#######################################
# Display dump help message
#######################################
function displayDumpHelp {
if  [ ! "$1" == ""  ]; then
    displayErrorMessage "database type '$1' IS NOT SUPPORTED"
fi
cat <<EOF
Dump one or all type of database

Usage:
  sx-dbtools dump [database-type]

Available Database type:
  mysql        Dump all mysql databases
  couchbase    Dump all couchbase buckets

Examples:
  # Dump all databases
  sx-dbtools dump
  # Dump only mysql databases
  sx-dbtools dump mysql
  # Dump only couchbase buckets
  sx-dbtools dump couchbase
EOF
exit 0;
}

#######################################
# Execute dump for all databases
#######################################
function doDumpGlobal {
    displayCommandMessage dump close
    doDumpMysqlAll
    doDumpCouchbaseAll
}


#######################################
# Execute dump for all mysql databases
#######################################
function doDumpMysqlAll {
    echo "- Dump all mysql database"
    checkMysqlEnv
    if checkMysqlDatabasesExist; then
        echo "  - mysql version : $DBM_ENV_MARIADB_VERSION"
        echo "  - server : $MYSQL_HOST"
        echo "  - database(s) : $MYSQL_DATABASE"
        echo "  - destination : $MYSQL_DUMP_DIR"
        dumpMysqlDatabaseAll
    else
        echo "  - mysql database(s) $MYSQL_DATABASE doesn't exist. Nothing to dump"
    fi
}

#######################################
# Execute dump for one mysql database
#######################################
function doDumpMysqlOne {
    echo "- Dump '$1' mysql database"
    checkMysqlEnv
    if checkMysqlDatabaseExist $1; then
        echo "  - mysql version : $DBM_ENV_MARIADB_VERSION"
        echo "  - server : $MYSQL_HOST"
        echo "  - database : $1"
        echo "  - destination : $MYSQL_DUMP_DIR"
        dumpMysqlDatabaseOne $1
    else
        echo "  - mysql database $1 doesn't exist. Nothing to dump"
    fi
}


#######################################
# Execute dump for all couchbase buckets
#######################################
function doDumpCouchbaseAll {
    echo "- Dump all couchbase buckets"
    checkCouchbaseEnv
    if checkCouchbaseIsNotInitialized; then
        echo "  - Couchbase host $COUCHBASE_HOST is not initialized. Nothing to dump"
    elif $(checkCouchbaseBucketExist); then
        echo "  - server : $COUCHBASE_HOST"
        echo "  - bucket(s) : $COUCHBASE_BUCKET"
        echo "  - destination : $COUCHBASE_DUMP_DIR"
        dumpCouchbaseBucketAll
    else
        echo "  - Couchbase bucket $COUCHBASE_BUCKET doesn't exist. Nothing to dump"
    fi
}

#######################################
# Execute dump for one couchbase bucket
#######################################
function doDumpCouchbaseOne {
    echo "- Dump '$1' couchbase bucket"
    checkCouchbaseEnv
    if checkCouchbaseIsNotInitialized; then
        echo "  - Couchbase host $COUCHBASE_HOST is not initialized. Nothing to dump"
    elif $(checkCouchbaseBucketExist); then
        echo "  - server : $COUCHBASE_HOST"
        echo "  - bucket : $1"
        echo "  - destination : $COUCHBASE_DUMP_DIR"
        dumpCouchbaseBucketOne $1
    else
        echo "  - Couchbase bucket $COUCHBASE_BUCKET doesn't exist. Nothing to dump"
    fi
}


#######################################
# dispatch across sub-command dump
#######################################
function dispatcherDump {
    displayStartupMessage
    displayCommandMessage $1
    case $2 in
        "") 
            doDumpGlobal; 
            displayEndMessage "dumping all mysql and couchbase database(s)" ;;
        mysql)
            displayDbtypeMessage $2 close;
            case $3 in
                "")
                    doDumpMysqlAll; 
                    displayEndMessage "dumping all mysql database(s)" ;;
                *)
                    doDumpMysqlOne $3; 
                    displayEndMessage "dumping mysql database $3" ;;
            esac
        ;;
        couchbase)  
            displayDbtypeMessage $2 close;
            case $3 in
                "")
                    doDumpCouchbaseAll; 
                    displayEndMessage "dumping all couchbase bucket(s)" ;;
                *)
                    doDumpCouchbaseOne $3; 
                    displayEndMessage "dumping couchbase bucket $3" ;;
            esac
        ;;
        help|--help)
            displayDumpHelp
        ;;
        *)
            displayDumpHelp $2 
        ;;
    esac
}










