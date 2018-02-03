#!/bin/bash

#######################################
# Display restore help message
#######################################
function displayRestoreHelp {
if  [ ! "$1" == ""  ]; then
    displayErrorMessage "database type '$1' IS NOT SUPPORTED"
fi
cat <<EOF
Restore one or all type of database

Usage:
  sx-dbtools restore [database-type]

Available Database type:
  mysql        Restore all mysql databases
  couchbase    Restore all couchbase buckets

Examples:
  # Restore all databases
  sx-dbtools restore
  # Restore only mysql databases
  sx-dbtools restore mysql
  # Restore only couchbase buckets
  sx-dbtools restore couchbase
EOF
exit 0;
}

#######################################
# Execute restore for all databases
#######################################
function doRestoreGlobal {
    displayCommandMessage restore close
    doRestoreMysqlAll
    doRestoreCouchbaseAll
}


#######################################
# Execute restore for all mysql databases
#######################################
function doRestoreMysqlAll {
    echo "- Restore all mysql database"
    checkMysqlEnv
    if checkMysqlDatabasesExist; then
        displayMysqlTabInfoBlock
        echo "  - database(s) : $MYSQL_DATABASE"
        echo "  - source : $MYSQL_DUMP_DIR"
        restoreMysqlDatabaseAll
    else
        echo "  - mysql database(s) $MYSQL_DATABASE doesn't exist. Nothing to restore"
    fi
}

#######################################
# Execute restore for one mysql database
#######################################
function doRestoreMysqlOne {
    echo "- Restore '$1' mysql database"
    checkMysqlEnv
    if checkMysqlDatabaseExist $1; then
        displayMysqlTabInfoBlock
        echo "  - database : $1"
        echo "  - source : $MYSQL_DUMP_DIR"
        restoreMysqlDatabaseOne $1
    else
        echo "  - mysql database $1 doesn't exist. Nothing to restore"
    fi
}


#######################################
# Execute restore for all couchbase buckets
#######################################
function doRestoreCouchbaseAll {
    echo "- Restore all couchbase buckets"
    checkCouchbaseEnv
    if checkCouchbaseIsNotInitialized; then
        echo "  - Couchbase host $COUCHBASE_HOST is not initialized. Nothing to restore"
    elif $(checkCouchbaseBucketsExist); then
        displayCouchbaseTabInfoBlock
        echo "  - bucket(s) : $COUCHBASE_BUCKET"
        echo "  - source : $COUCHBASE_DUMP_DIR"
        restoreCouchbaseBucketAll
    else
        echo "  - Couchbase bucket $COUCHBASE_BUCKET doesn't exist. Nothing to restore"
    fi
}

#######################################
# Execute restore for one couchbase bucket
#######################################
function doRestoreCouchbaseOne {
    echo "- Restore '$1' couchbase bucket"
    checkCouchbaseEnv
    if checkCouchbaseIsNotInitialized; then
        echo "  - Couchbase host $COUCHBASE_HOST is not initialized. Nothing to restore"
    elif $(checkCouchbaseBucketsExist); then
        displayCouchbaseTabInfoBlock
        echo "  - bucket : $1"
        echo "  - source : $COUCHBASE_DUMP_DIR"
        restoreCouchbaseBucketOne $1
    else
        echo "  - Couchbase bucket $COUCHBASE_BUCKET doesn't exist. Nothing to restore"
    fi
}


#######################################
# dispatch across sub-command restore
#######################################
function dispatcherRestore {
    displayStartupMessage
    displayCommandMessage $1
    case $2 in
        "") 
            doRestoreGlobal; 
            displayEndMessage "restoring all mysql and couchbase database(s)" ;;
        mysql)
            displayDbtypeMessage $2 close;
            case $3 in
                "")
                    doRestoreMysqlAll; 
                    displayEndMessage "restoring all mysql database(s)" ;;
                *)
                    doRestoreMysqlOne $3; 
                    displayEndMessage "restoring mysql database $3" ;;
            esac
        ;;
        couchbase)  
            displayDbtypeMessage $2 close;
            case $3 in
                "")
                    doRestoreCouchbaseAll; 
                    displayEndMessage "restoring all couchbase bucket(s)" ;;
                *)
                    doRestoreCouchbaseOne $3; 
                    displayEndMessage "restoring couchbase bucket $3" ;;
            esac
        ;;
        help|--help)
            displayRestoreHelp
        ;;
        *)
            displayRestoreHelp $2 
        ;;
    esac
}










