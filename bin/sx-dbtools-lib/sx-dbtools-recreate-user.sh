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
    displayDebugMessage "recreate-user : doRecreateUserGlobal()"
    doRecreateUserMysqlAll
    doRecreateUserCouchbaseAll
}


#######################################
# Execute recreate-user for all mysql user(s)
#######################################
function doRecreateUserMysqlAll {
    displayDebugMessage "recreate-user : doRecreateUserMysqlAll()"
    echo "- Recreate all mysql user(s)"
    checkMysqlEnv
    displayMysqlTabInfoBlock
    echo "  - user(s) : $MYSQL_DATABASE"
    deleteMysqlUsers
    createMysqlUsers
}

#######################################
# Execute recreate-user for one mysql user
#######################################
function doRecreateUserMysqlOne {
    displayDebugMessage "recreate-user : doRecreateUserMysqlOne()"
    echo "- Recreate '$1' mysql user"
    checkMysqlEnv
    displayMysqlTabInfoBlock
    echo "  - user : $1"
    deleteMysqlUser $1
    createMysqlUser $1
}


#######################################
# Execute recreate-user for all couchbase user(s)
#######################################
function doRecreateUserCouchbaseAll {
    displayDebugMessage "recreate-user : doRecreateUserCouchbaseAll()"
    echo "- Recreate all couchbase user(s)"
    checkCouchbaseEnv
    displayCouchbaseTabInfoBlock
    echo "  - user(s) : $COUCHBASE_USERS"
    deleteCouchbaseUsers
    createCouchbaseUsers
}

#######################################
# Execute recreate-user for one couchbase user
#######################################
function doRecreateUserCouchbaseOne {
    displayDebugMessage "recreate-user : doRecreateUserCouchbaseOne()"
    echo "- Recreate '$1' couchbase user"
    checkCouchbaseEnv
    displayCouchbaseTabInfoBlock
    echo "  - user : $1"
    deleteCouchbaseUser $1
    createCouchbaseUser $1
}


#######################################
# dispatch across sub-command recreate-user
#######################################
function dispatcherRecreateUser {
    displayStartupMessage
    case $2 in
        "") 
            displayCommandMessage $1 close
            doRecreateUserGlobal; 
            displayEndMessage "recreating all mysql and couchbase user(s)" ;;
        mysql)
            displayCommandMessage $1
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
            displayCommandMessage $1
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
            displayCommandMessage help close
            displayRecreateUserHelp
        ;;
        *)
            displayCommandMessage unknown close
            displayRecreateUserHelp $2 
        ;;
    esac
}










