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
    displayDebugMessage "dump : doDumpGlobal()"
    doDumpMysqlAll
    doDumpCouchbaseAll
}


#######################################
# Execute dump for all mysql databases
#######################################
function doDumpMysqlAll {
    displayDebugMessage "dump : doDumpMysqlAll()"
    echo "- Dump all mysql database"
    checkMysqlEnv
    if checkMysqlDatabasesExist; then
        displayMysqlTabInfoBlock
        echo "  - database(s) : $MYSQL_DATABASE"
        echo "  - destination : $MYSQL_DUMP_DIR"
        dumpMysqlDatabases
    else
        echo "  - mysql database(s) $MYSQL_DATABASE doesn't exist. Nothing to dump"
    fi
}

#######################################
# Execute dump for one mysql database
#######################################
function doDumpMysqlOne {
    displayDebugMessage "dump : doDumpMysqlOne()"
    echo "- Dump '$1' mysql database"
    checkMysqlEnv
    if checkMysqlDatabaseExist $1; then
        displayMysqlTabInfoBlock
        echo "  - database : $1"
        echo "  - destination : $MYSQL_DUMP_DIR"
        dumpMysqlDatabase $1
    else
        echo "  - mysql database $1 doesn't exist. Nothing to dump"
    fi
}


#######################################
# Execute dump for all couchbase buckets
#######################################
function doDumpCouchbaseAll {
    displayDebugMessage "dump : doDumpCouchbaseAll()"
    echo "- Dump all couchbase buckets"
    checkCouchbaseEnv
    if checkCouchbaseIsNotInitialized; then
        echo "  - Couchbase host $COUCHBASE_HOST is not initialized. Nothing to dump"
    elif $(checkCouchbaseBucketsExist); then
        displayCouchbaseTabInfoBlock
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
    displayDebugMessage "dump : doDumpCouchbaseOne()"
    echo "- Dump '$1' couchbase bucket"
    checkCouchbaseEnv
    if checkCouchbaseIsNotInitialized; then
        echo "  - Couchbase host $COUCHBASE_HOST is not initialized. Nothing to dump"
    elif $(checkCouchbaseBucketsExist); then
        displayCouchbaseTabInfoBlock
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
    case $2 in
        "") 
            displayCommandMessage $1 close
            doDumpGlobal; 
            displayEndMessage "dumping all mysql and couchbase database(s)" ;;
        mysql)
            displayCommandMessage $1
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
            displayCommandMessage $1
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
            displayCommandMessage help close
            displayDumpHelp
        ;;
        *)
            displayCommandMessage unknown close
            displayDumpHelp $2 
        ;;
    esac
}










