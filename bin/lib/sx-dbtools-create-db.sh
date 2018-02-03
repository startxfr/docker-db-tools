#!/bin/bash

#######################################
# Display create-db help message
#######################################
function displayCreateDbHelp {
if  [ ! "$1" == ""  ]; then
    displayErrorMessage "database type '$1' IS NOT SUPPORTED"
fi
cat <<EOF
Create one or all type of database

Usage:
  sx-dbtools create-db [database-type]

Available Database type:
  mysql        Create all mysql databases
  couchbase    Create all couchbase buckets

Examples:
  # Create all databases
  sx-dbtools create-db
  # Create only mysql databases
  sx-dbtools create-db mysql
  # Create only couchbase buckets
  sx-dbtools create-db couchbase
EOF
exit 0;
}

#######################################
# Execute create-db for all databases
#######################################
function doCreateDbGlobal {
    doCreateDbMysqlAll
    doCreateDbCouchbaseAll
}


#######################################
# Execute create-db for all mysql databases
#######################################
function doCreateDbMysqlAll {
    echo "- Create all mysql database"
    checkMysqlEnv
    if ! checkMysqlDatabasesExist; then
        displayMysqlTabInfoBlock
        echo "  - database(s) : $MYSQL_DATABASE"
        createMysqlDatabases
    else
        echo "  - mysql database(s) $MYSQL_DATABASE exist, delete or recreate instead."
    fi
}

#######################################
# Execute create-db for one mysql database
#######################################
function doCreateDbMysqlOne {
    echo "- Create '$1' mysql database"
    checkMysqlEnv
    if ! checkMysqlDatabaseExist $1; then
        displayMysqlTabInfoBlock
        echo "  - database : $1"
        createMysqlDatabase $1
    else
        echo "  - mysql database $1 exist, delete or recreate instead."
    fi
}


#######################################
# Execute create-db for all couchbase buckets
#######################################
function doCreateDbCouchbaseAll {
    echo "- Create all couchbase buckets"
    checkCouchbaseEnv
    if $(checkCouchbaseBucketsExist); then
        echo "  - Couchbase host $COUCHBASE_HOST has bucket(s), try to recreate instead."
    else
        displayCouchbaseTabInfoBlock
        echo "  - bucket(s) : $COUCHBASE_BUCKET"
        createCouchbaseBuckets
    fi
}

#######################################
# Execute create-db for one couchbase bucket
#######################################
function doCreateDbCouchbaseOne {
    echo "- Create '$1' couchbase bucket"
    checkCouchbaseEnv
    if $(checkCouchbaseBucketExist $1); then
        echo "  - Couchbase host $COUCHBASE_HOST already has bucket $1, try to recreate instead."
    else
        displayCouchbaseTabInfoBlock
        echo "  - bucket : $1"
        createCouchbaseBucket $1
    fi
}


#######################################
# dispatch across sub-command create-db
#######################################
function dispatcherCreateDb {
    displayStartupMessage
    case $2 in
        "") 
            displayCommandMessage $1 close
            doCreateDbGlobal; 
            displayEndMessage "creating all mysql and couchbase database(s)" ;;
        mysql)
            displayCommandMessage $1
            displayDbtypeMessage $2 close;
            case $3 in
                "")
                    doCreateDbMysqlAll; 
                    displayEndMessage "creating all mysql database(s)" ;;
                *)
                    doCreateDbMysqlOne $3; 
                    displayEndMessage "creating mysql database $3" ;;
            esac
        ;;
        couchbase)  
            displayCommandMessage $1
            displayDbtypeMessage $2 close;
            case $3 in
                "")
                    doCreateDbCouchbaseAll; 
                    displayEndMessage "creating all couchbase bucket(s)" ;;
                *)
                    doCreateDbCouchbaseOne $3; 
                    displayEndMessage "creating couchbase bucket $3" ;;
            esac
        ;;
        help|--help)
            displayCommandMessage help close
            displayCreateDbHelp
        ;;
        *)
            displayCommandMessage unknown close
            displayCreateDbHelp $2 
        ;;
    esac
}










