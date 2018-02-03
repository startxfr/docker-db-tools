#!/bin/bash

#######################################
# Display recreate-db help message
#######################################
function displayRecreateDbHelp {
if  [ ! "$1" == ""  ]; then
    displayErrorMessage "database type '$1' IS NOT SUPPORTED"
fi
cat <<EOF
Recreate one or all type of database

Usage:
  sx-dbtools recreate-db [database-type]

Available Database type:
  mysql        Recreate all mysql databases
  couchbase    Recreate all couchbase buckets

Examples:
  # Recreate all databases
  sx-dbtools recreate-db
  # Recreate only mysql databases
  sx-dbtools recreate-db mysql
  # Recreate only couchbase buckets
  sx-dbtools recreate-db couchbase
EOF
exit 0;
}

#######################################
# Execute recreate-db for all databases
#######################################
function doRecreateDbGlobal {
    displayCommandMessage recreate-db close
    doRecreateDbMysqlAll
    doRecreateDbCouchbaseAll
}


#######################################
# Execute recreate-db for all mysql databases
#######################################
function doRecreateDbMysqlAll {
    echo "- Recreate all mysql database"
    checkMysqlEnv
    if checkMysqlDatabasesExist; then
        displayMysqlTabInfoBlock
        echo "  - database(s) : $MYSQL_DATABASE"
        deleteMysqlDatabases
    else
        echo "  - mysql database(s) $MYSQL_DATABASE doesn't exist, nothing to delete."
    fi
    createMysqlDatabases
}

#######################################
# Execute recreate-db for one mysql database
#######################################
function doRecreateDbMysqlOne {
    echo "- Recreate '$1' mysql database"
    checkMysqlEnv
    if checkMysqlDatabaseExist $1; then
        displayMysqlTabInfoBlock
        echo "  - database : $1"
        deleteMysqlDatabase $1
    else
        echo "  - mysql database $1 doesn't exist, nothing to delete."
    fi
    createMysqlDatabase $1
}


#######################################
# Execute recreate-db for all couchbase buckets
#######################################
function doRecreateDbCouchbaseAll {
    echo "- Recreate all couchbase buckets"
    checkCouchbaseEnv
    if $(checkCouchbaseBucketsExist); then
        displayCouchbaseTabInfoBlock
        echo "  - bucket(s) : $COUCHBASE_BUCKET"
        deleteCouchbaseBuckets
    else
        echo "  - Couchbase host $COUCHBASE_HOST has no bucket, nothing to delete."
    fi
    createCouchbaseBuckets
}

#######################################
# Execute recreate-db for one couchbase bucket
#######################################
function doRecreateDbCouchbaseOne {
    echo "- Recreate '$1' couchbase bucket"
    checkCouchbaseEnv
    if $(checkCouchbaseBucketExist $1); then
        displayCouchbaseTabInfoBlock
        echo "  - bucket : $1"
        deleteCouchbaseBucket $1
    else
        echo "  - Couchbase host $COUCHBASE_HOST has no '$1' bucket, nothing to delete."
    fi
    createCouchbaseBucket $1
}


#######################################
# dispatch across sub-command recreate-db
#######################################
function dispatcherRecreateDb {
    displayStartupMessage
    displayCommandMessage $1
    case $2 in
        "") 
            doRecreateDbGlobal; 
            displayEndMessage "recreating all mysql and couchbase database(s)" ;;
        mysql)
            displayDbtypeMessage $2 close;
            case $3 in
                "")
                    doRecreateDbMysqlAll; 
                    displayEndMessage "recreating all mysql database(s)" ;;
                *)
                    doRecreateDbMysqlOne $3; 
                    displayEndMessage "recreating mysql database $3" ;;
            esac
        ;;
        couchbase)  
            displayDbtypeMessage $2 close;
            case $3 in
                "")
                    doRecreateDbCouchbaseAll; 
                    displayEndMessage "recreating all couchbase bucket(s)" ;;
                *)
                    doRecreateDbCouchbaseOne $3; 
                    displayEndMessage "recreating couchbase bucket $3" ;;
            esac
        ;;
        help|--help)
            displayRecreateDbHelp
        ;;
        *)
            displayRecreateDbHelp $2 
        ;;
    esac
}










