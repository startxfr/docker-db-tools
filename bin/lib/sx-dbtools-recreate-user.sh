#!/bin/bash

#######################################
# Display recreate-user help message
#######################################
function displayRecreateUserHelp {
if  [ ! "$1" == ""  ]; then
    displayErrorMessage "database type '$1' IS NOT SUPPORTED"
fi
cat <<EOF
Recreate one or all type of database(s) user(s)

Usage:
  sx-dbtools recreate-user [database-type]

Available Database type:
  mysql        Recreate all mysql user(s)
  couchbase    Recreate all couchbase user(s)

Examples:
  # Recreate all database(s) user(s)
  sx-dbtools recreate-user
  # Recreate only mysql user(s)
  sx-dbtools recreate-user mysql
  # Recreate only couchbase user(s)
  sx-dbtools recreate-user couchbase
EOF
exit 0;
}

#######################################
# Execute recreate-user for all database(s) user(s)
#######################################
function doRecreateUserGlobal {
    displayCommandMessage recreate-user close
    doRecreateUserMysqlAll
    doRecreateUserCouchbaseAll
}


#######################################
# Execute recreate-user for all mysql user(s)
#######################################
function doRecreateUserMysqlAll {
    echo "- Recreate all mysql user(s)"
    checkMysqlEnv
    displayMysqlTabInfoBlock
    echo "  - user(s) : $MYSQL_DATABASE"
    deleteMysqlDatabases
    createMysqlDatabases
}

#######################################
# Execute recreate-user for one mysql user
#######################################
function doRecreateUserMysqlOne {
    echo "- Recreate '$1' mysql user"
    checkMysqlEnv
    displayMysqlTabInfoBlock
    echo "  - user : $1"
    deleteMysqlDatabase $1
    createMysqlDatabase $1
}


#######################################
# Execute recreate-user for all couchbase user(s)
#######################################
function doRecreateUserCouchbaseAll {
    echo "- Recreate all couchbase user(s)"
    checkCouchbaseEnv
    displayCouchbaseTabInfoBlock
    echo "  - user(s) : $COUCHBASE_USERS"
    deleteCouchbaseBuckets
    createCouchbaseBuckets
}

#######################################
# Execute recreate-user for one couchbase user
#######################################
function doRecreateUserCouchbaseOne {
    echo "- Recreate '$1' couchbase user"
    checkCouchbaseEnv
    displayCouchbaseTabInfoBlock
    echo "  - user : $1"
    deleteCouchbaseBucket $1
    createCouchbaseBucket $1
}


#######################################
# dispatch across sub-command recreate-user
#######################################
function dispatcherRecreateUser {
    displayStartupMessage
    displayCommandMessage $1
    case $2 in
        "") 
            doRecreateUserGlobal; 
            displayEndMessage "recreating all mysql and couchbase user(s)" ;;
        mysql)
            displayDbtypeMessage $2 close;
            case $3 in
                "")
                    doRecreateUserMysqlAll; 
                    displayEndMessage "recreating all mysql user(s)" ;;
                *)
                    doRecreateUserMysqlOne $3; 
                    displayEndMessage "recreating mysql user $3" ;;
            esac
        ;;
        couchbase)  
            displayDbtypeMessage $2 close;
            case $3 in
                "")
                    doRecreateUserCouchbaseAll; 
                    displayEndMessage "recreating all couchbase user(s)" ;;
                *)
                    doRecreateUserCouchbaseOne $3; 
                    displayEndMessage "recreating couchbase user $3" ;;
            esac
        ;;
        help|--help)
            displayRecreateUserHelp
        ;;
        *)
            displayRecreateUserHelp $2 
        ;;
    esac
}










