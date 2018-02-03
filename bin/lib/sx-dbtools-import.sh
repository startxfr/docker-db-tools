#!/bin/bash

#######################################
# Display import help message
#######################################
function displayImportHelp {
if  [ ! "$1" == ""  ]; then
    displayErrorMessage "database type '$1' IS NOT SUPPORTED"
fi
cat <<EOF
Import one or all type of database

Usage:
  sx-dbtools import [database-type]

Available Database type:
  mysql        Import all mysql databases
  couchbase    Import all couchbase buckets

Examples:
  # Import all databases
  sx-dbtools import
  # Import only mysql databases
  sx-dbtools import mysql
  # Import only couchbase buckets
  sx-dbtools import couchbase
EOF
exit 0;
}

#######################################
# Execute import for all databases
#######################################
function doImportGlobal {
    displayCommandMessage import close
    doImportMysqlAll
    doImportCouchbaseAll
}


#######################################
# Execute import for all mysql databases
#######################################
function doImportMysqlAll {
    echo "- Import all mysql database"
    checkMysqlEnv
    if checkMysqlDatabasesExist; then
        displayMysqlTabInfoBlock
        echo "  - database(s) : $MYSQL_DATABASE"
        echo "  - source : $MYSQL_DUMP_DIR"
        importMysqlDatabaseAll
    else
        echo "  - mysql database(s) $MYSQL_DATABASE doesn't exist. Nothing to import"
    fi
}

#######################################
# Execute import for one mysql database
#######################################
function doImportMysqlOne {
    echo "- Import '$1' mysql database"
    checkMysqlEnv
    if checkMysqlDatabaseExist $1; then
        displayMysqlTabInfoBlock
        echo "  - database : $1"
        echo "  - source : $MYSQL_DUMP_DIR"
        importMysqlDatabaseOne $1
    else
        echo "  - mysql database $1 doesn't exist. Nothing to import"
    fi
}


#######################################
# Execute import for all couchbase buckets
#######################################
function doImportCouchbaseAll {
    echo "- Import all couchbase buckets"
    checkCouchbaseEnv
    if checkCouchbaseIsNotInitialized; then
        echo "  - Couchbase host $COUCHBASE_HOST is not initialized. Nothing to import"
    elif $(checkCouchbaseBucketsExist); then
        displayCouchbaseTabInfoBlock
        echo "  - bucket(s) : $COUCHBASE_BUCKET"
        echo "  - source : $COUCHBASE_DUMP_DIR"
        importCouchbaseBucketAll
    else
        echo "  - Couchbase bucket $COUCHBASE_BUCKET doesn't exist. Nothing to import"
    fi
}

#######################################
# Execute import for one couchbase bucket
#######################################
function doImportCouchbaseOne {
    echo "- Import '$1' couchbase bucket"
    checkCouchbaseEnv
    if checkCouchbaseIsNotInitialized; then
        echo "  - Couchbase host $COUCHBASE_HOST is not initialized. Nothing to import"
    elif $(checkCouchbaseBucketsExist); then
        displayCouchbaseTabInfoBlock
        echo "  - bucket : $1"
        echo "  - source : $COUCHBASE_DUMP_DIR"
        importCouchbaseBucketOne $1
    else
        echo "  - Couchbase bucket $COUCHBASE_BUCKET doesn't exist. Nothing to import"
    fi
}


#######################################
# dispatch across sub-command import
#######################################
function dispatcherImport {
    displayStartupMessage
    displayCommandMessage $1
    case $2 in
        "") 
            doImportGlobal; 
            displayEndMessage "importing all mysql and couchbase database(s)" ;;
        mysql)
            displayDbtypeMessage $2 close;
            case $3 in
                "")
                    doImportMysqlAll; 
                    displayEndMessage "importing all mysql database(s)" ;;
                *)
                    doImportMysqlOne $3; 
                    displayEndMessage "importing mysql database $3" ;;
            esac
        ;;
        couchbase)  
            displayDbtypeMessage $2 close;
            case $3 in
                "")
                    doImportCouchbaseAll; 
                    displayEndMessage "importing all couchbase bucket(s)" ;;
                *)
                    doImportCouchbaseOne $3; 
                    displayEndMessage "importing couchbase bucket $3" ;;
            esac
        ;;
        help|--help)
            displayImportHelp
        ;;
        *)
            displayImportHelp $2 
        ;;
    esac
}










