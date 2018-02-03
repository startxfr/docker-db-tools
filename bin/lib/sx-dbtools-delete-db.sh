#!/bin/bash

#######################################
# Display delete-db help message
#######################################
function displayDeleteDbHelp {
if  [ ! "$1" == ""  ]; then
    displayErrorMessage "database type '$1' IS NOT SUPPORTED"
fi
cat <<EOF
Delete one or all type of database

Usage:
  sx-dbtools delete-db [database-type]

Available Database type:
  mysql        Delete all mysql databases
  couchbase    Delete all couchbase buckets

Examples:
  # Delete all databases
  sx-dbtools delete-db
  # Delete only mysql databases
  sx-dbtools delete-db mysql
  # Delete only couchbase buckets
  sx-dbtools delete-db couchbase
EOF
exit 0;
}

#######################################
# Execute delete-db for all databases
#######################################
function doDeleteDbGlobal {
    displayCommandMessage delete-db close
    doDeleteDbMysqlAll
    doDeleteDbCouchbaseAll
}


#######################################
# Execute delete-db for all mysql databases
#######################################
function doDeleteDbMysqlAll {
    echo "- Delete all mysql database"
    checkMysqlEnv
    if checkMysqlDatabasesExist; then
        displayMysqlTabInfoBlock
        echo "  - database(s) : $MYSQL_DATABASE"
        deleteMysqlDatabases
    else
        echo "  - mysql database(s) $MYSQL_DATABASE doesn't exist, try to create instead."
    fi
}

#######################################
# Execute delete-db for one mysql database
#######################################
function doDeleteDbMysqlOne {
    echo "- Delete '$1' mysql database"
    checkMysqlEnv
    if checkMysqlDatabaseExist $1; then
        displayMysqlTabInfoBlock
        echo "  - database : $1"
        deleteMysqlDatabase $1
    else
        echo "  - mysql database $1 doesn't exist, try to create instead."
    fi
}


#######################################
# Execute delete-db for all couchbase buckets
#######################################
function doDeleteDbCouchbaseAll {
    echo "- Delete all couchbase buckets"
    checkCouchbaseEnv
    if $(checkCouchbaseBucketsExist); then
        displayCouchbaseTabInfoBlock
        echo "  - bucket(s) : $COUCHBASE_BUCKET"
        deleteCouchbaseBuckets
    else
        echo "  - Couchbase host $COUCHBASE_HOST has no bucket, try to create instead."
    fi
}

#######################################
# Execute delete-db for one couchbase bucket
#######################################
function doDeleteDbCouchbaseOne {
    echo "- Delete '$1' couchbase bucket"
    checkCouchbaseEnv
    if $(checkCouchbaseBucketExist $1); then
        displayCouchbaseTabInfoBlock
        echo "  - bucket : $1"
        deleteCouchbaseBucket $1
    else
        echo "  - Couchbase host $COUCHBASE_HOST has no '$1' bucket, try to create instead."
    fi
}


#######################################
# dispatch across sub-command delete-db
#######################################
function dispatcherDeleteDb {
    displayStartupMessage
    displayCommandMessage $1
    case $2 in
        "") 
            doDeleteDbGlobal; 
            displayEndMessage "deleting all mysql and couchbase database(s)" ;;
        mysql)
            displayDbtypeMessage $2 close;
            case $3 in
                "")
                    doDeleteDbMysqlAll; 
                    displayEndMessage "deleting all mysql database(s)" ;;
                *)
                    doDeleteDbMysqlOne $3; 
                    displayEndMessage "deleting mysql database $3" ;;
            esac
        ;;
        couchbase)  
            displayDbtypeMessage $2 close;
            case $3 in
                "")
                    doDeleteDbCouchbaseAll; 
                    displayEndMessage "deleting all couchbase bucket(s)" ;;
                *)
                    doDeleteDbCouchbaseOne $3; 
                    displayEndMessage "deleting couchbase bucket $3" ;;
            esac
        ;;
        help|--help)
            displayDeleteDbHelp
        ;;
        *)
            displayDeleteDbHelp $2 
        ;;
    esac
}










