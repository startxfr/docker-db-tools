#!/bin/bash

#######################################
# Display delete help message
#######################################
function displayDeleteHelp {
if  [ ! "$1" == ""  ]; then
    displayErrorMessage "database type '$1' IS NOT SUPPORTED"
fi
cat <<EOF
Delete database(s), user(s) and data for one or all type of database(s)

Usage:
  sx-dbtools delete [database-type]

Available Database type:
  mysql        Delete all mysql database(s), user(s) and data
  couchbase    Delete all couchbase database(s), user(s) and data

Examples:
  # Delete all database(s), user(s) and data
  sx-dbtools delete
  # Delete only mysql database(s), user(s) and data
  sx-dbtools delete mysql
  # Delete only couchbase database(s), user(s) and data
  sx-dbtools delete couchbase
EOF
exit 0;
}

#######################################
# Execute delete for all database(s), user(s) and data
#######################################
function doDeleteGlobal {
    doDeleteMysqlAll
    doDeleteCouchbaseAll
}


#######################################
# Execute delete for all mysql database(s), user(s) and data
#######################################
function doDeleteMysqlAll {
    echo "- Delete all mysql database(s) and user(s)"
    checkMysqlEnv
    displayMysqlTabInfoBlock
    echo "  - database(s) : $MYSQL_DATABASE"
    echo "  - user(s) : $MYSQL_USERS"
    deleteMysqlDatabases
    deleteMysqlUsers
}


#######################################
# Execute delete for all couchbase bucket(s), user(s) and data
#######################################
function doDeleteCouchbaseAll {
    echo "- Delete all couchbase bucket(s) and user(s)"
    checkCouchbaseEnv
    displayCouchbaseTabInfoBlock
    echo "  - bucket(s) : $COUCHBASE_BUCKET"
    echo "  - user(s) : $COUCHBASE_USERS"
    deleteCouchbaseBuckets
    deleteCouchbaseUsers
}


#######################################
# dispatch across sub-command delete
#######################################
function dispatcherDelete {
    displayStartupMessage
    case $2 in
        "") 
            displayCommandMessage $1 close
            doDeleteGlobal; 
            displayEndMessage "deleting all mysql and couchbase database(s), user(s) and data" ;;
        mysql)
            displayCommandMessage $1
            displayDbtypeMessage $2 close;
            case $3 in
                "")
                    doDeleteMysqlAll; 
                    displayEndMessage "deleting all mysql database(s), user(s) and data" ;;
                *)
                    displayDeleteHelp ;;
            esac
        ;;
        couchbase)  
            displayCommandMessage $1
            displayDbtypeMessage $2 close;
            case $3 in
                "")
                    doDeleteCouchbaseAll; 
                    displayEndMessage "deleting all couchbase database(s), user(s) and data" ;;
                *)
                    displayDeleteHelp ;;
            esac
        ;;
        help|--help)
            displayCommandMessage help close
            displayDeleteHelp
        ;;
        *)
            displayCommandMessage unknown close
            displayDeleteHelp $2 
        ;;
    esac
}










