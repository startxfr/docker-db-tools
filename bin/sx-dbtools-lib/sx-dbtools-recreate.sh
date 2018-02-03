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
    doRecreateMysqlAll
    doRecreateCouchbaseAll
}


#######################################
# Execute recreate for all mysql database(s), user(s) and data
#######################################
function doRecreateMysqlAll {
    echo "- Recreate all mysql database(s), user(s) and data"
    checkMysqlEnv
    displayMysqlTabInfoBlock
    echo "  - database(s) : $MYSQL_DATABASE"
    echo "  - user(s) : $MYSQL_USERS"
    echo "  - source : $MYSQL_DUMP_DIR"
    deleteMysqlDatabases
    deleteMysqlUsers
    createMysqlDatabases
    createMysqlUsers
    importMysqlDatabases
}


#######################################
# Execute recreate for all couchbase bucket(s), user(s) and data
#######################################
function doRecreateCouchbaseAll {
    echo "- Recreate all couchbase bucket(s), user(s) and data"
    checkCouchbaseEnv
    displayCouchbaseTabInfoBlock
    echo "  - bucket(s) : $COUCHBASE_BUCKET"
    echo "  - user(s) : $COUCHBASE_USERS"
    echo "  - source : $COUCHBASE_DUMP_DIR"
    deleteCouchbaseBuckets
    deleteCouchbaseUsers
    createCouchbaseBuckets
    createCouchbaseUsers
    importCouchbaseBuckets
}


#######################################
# dispatch across sub-command recreate
#######################################
function dispatcherRecreate {
    displayStartupMessage
    case $2 in
        "") 
            displayCommandMessage $1 close
            doRecreateGlobal; 
            displayEndMessage "recreating all mysql and couchbase database(s), user(s) and data" ;;
        mysql)
            displayCommandMessage $1
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
            displayCommandMessage $1
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
            displayCommandMessage help close
            displayRecreateHelp
        ;;
        *)
            displayCommandMessage unknown close
            displayRecreateHelp $2 
        ;;
    esac
}










