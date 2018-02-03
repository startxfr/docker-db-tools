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
    displayCommandMessage delete close
    doDeleteMysqlAll
    doDeleteCouchbaseAll
}


#######################################
# Execute delete for all mysql database(s), user(s) and data
#######################################
function doDeleteMysqlAll {
    echo "- Delete all mysql user(s)"
    checkMysqlEnv
    displayMysqlTabInfoBlock
    echo "  - user(s) : $MYSQL_USERS"
    deleteMysqlDatabases
}


#######################################
# Execute delete for all couchbase database(s), user(s) and data
#######################################
function doDeleteCouchbaseAll {
    echo "- Delete all couchbase user(s)"
    checkCouchbaseEnv
    displayCouchbaseTabInfoBlock
    echo "  - user(s) : $COUCHBASE_USERS"
    deleteCouchbaseBuckets
}


#######################################
# dispatch across sub-command delete
#######################################
function dispatcherDelete {
    displayStartupMessage
    displayCommandMessage $1
    case $2 in
        "") 
            doDeleteGlobal; 
            displayEndMessage "deleting all mysql and couchbase database(s), user(s) and data" ;;
        mysql)
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
            displayDeleteHelp
        ;;
        *)
            displayDeleteHelp $2 
        ;;
    esac
}










