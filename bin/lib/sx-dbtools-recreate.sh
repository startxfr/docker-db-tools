#!/bin/bash

#######################################
# Display recreate help message
#######################################
function displayRecreateHelp {
if  [ ! "$1" == ""  ]; then
    displayErrorMessage "database type '$1' IS NOT SUPPORTED"
fi
cat <<EOF
Recreate database(s), user(s) and data for one or all type of database(s)

Usage:
  sx-dbtools recreate [database-type]

Available Database type:
  mysql        Recreate all mysql database(s), user(s) and data
  couchbase    Recreate all couchbase database(s), user(s) and data

Examples:
  # Recreate all database(s), user(s) and data
  sx-dbtools recreate
  # Recreate only mysql database(s), user(s) and data
  sx-dbtools recreate mysql
  # Recreate only couchbase database(s), user(s) and data
  sx-dbtools recreate couchbase
EOF
exit 0;
}

#######################################
# Execute recreate for all database(s), user(s) and data
#######################################
function doRecreateGlobal {
    displayCommandMessage recreate close
    doRecreateMysqlAll
    doRecreateCouchbaseAll
}


#######################################
# Execute recreate for all mysql database(s), user(s) and data
#######################################
function doRecreateMysqlAll {
    echo "- Recreate all mysql user(s)"
    checkMysqlEnv
    displayMysqlTabInfoBlock
    echo "  - user(s) : $MYSQL_DATABASE"
    deleteMysqlDatabases
    createMysqlDatabases
}


#######################################
# Execute recreate for all couchbase user(s)
#######################################
function doRecreateCouchbaseAll {
    echo "- Recreate all couchbase user(s)"
    checkCouchbaseEnv
    displayCouchbaseTabInfoBlock
    echo "  - user(s) : $COUCHBASE_USERS"
    deleteCouchbaseBuckets
    createCouchbaseBuckets
}


#######################################
# dispatch across sub-command recreate
#######################################
function dispatcherRecreate {
    displayStartupMessage
    displayCommandMessage $1
    case $2 in
        "") 
            doRecreateGlobal; 
            displayEndMessage "recreating all mysql and couchbase database(s), user(s) and data" ;;
        mysql)
            displayDbtypeMessage $2 close;
            case $3 in
                "")
                    doRecreateMysqlAll; 
                    displayEndMessage "recreating all mysql database(s), user(s) and data" ;;
                *)
                    displayRecreateHelp ;;
            esac
        ;;
        couchbase)  
            displayDbtypeMessage $2 close;
            case $3 in
                "")
                    doRecreateCouchbaseAll; 
                    displayEndMessage "recreating all couchbase database(s), user(s) and data" ;;
                *)
                    displayRecreateHelp ;;
            esac
        ;;
        help|--help)
            displayRecreateHelp
        ;;
        *)
            displayRecreateHelp $2 
        ;;
    esac
}










