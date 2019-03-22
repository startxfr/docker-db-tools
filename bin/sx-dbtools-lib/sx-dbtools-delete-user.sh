#!/bin/bash

#######################################
# Display delete-user help message
#######################################
function displayDeleteUserHelp {
if  [ ! "$1" == ""  ]; then
    displayErrorMessage "database type '$1' IS NOT SUPPORTED"
fi
cat <<EOF
Delete one or all type of database(s) user(s)

Usage:
  sx-dbtools delete-user [database-type]

Available Database type:
  mysql        Delete all mysql user(s)
  couchbase    Delete all couchbase user(s)

Examples:
  # Delete all database(s) user(s)
  sx-dbtools delete-user
  # Delete only mysql user(s)
  sx-dbtools delete-user mysql
  # Delete only couchbase user(s)
  sx-dbtools delete-user couchbase
EOF
exit 0;
}

#######################################
# Execute delete-user for all database(s) user(s)
#######################################
function doDeleteUserGlobal {
    displayDebugMessage "delete-user : doDeleteUserGlobal()"
    doDeleteUserMysqlAll
    doDeleteUserCouchbaseAll
}


#######################################
# Execute delete-user for all mysql user(s)
#######################################
function doDeleteUserMysqlAll {
    displayDebugMessage "delete-user : doDeleteUserMysqlAll()"
    echo "- Delete all mysql user(s)"
    checkMysqlEnv
    displayMysqlTabInfoBlock
    echo "  - user(s) : $MYSQL_USERS"
    deleteMysqlUsers
}

#######################################
# Execute delete-user for one mysql user
#######################################
function doDeleteUserMysqlOne {
    displayDebugMessage "delete-user : doDeleteUserMysqlOne()"
    echo "- Delete '$1' mysql user"
    checkMysqlEnv
    displayMysqlTabInfoBlock
    echo "  - user : $1"
    deleteMysqlUser $1
}


#######################################
# Execute delete-user for all couchbase user(s)
#######################################
function doDeleteUserCouchbaseAll {
    displayDebugMessage "delete-user : doDeleteUserCouchbaseAll()"
    echo "- Delete all couchbase user(s)"
    checkCouchbaseEnv
    displayCouchbaseTabInfoBlock
    echo "  - user(s) : $COUCHBASE_USERS"
    deleteCouchbaseBuckets
}

#######################################
# Execute delete-user for one couchbase user
#######################################
function doDeleteUserCouchbaseOne {
    displayDebugMessage "delete-user : doDeleteUserCouchbaseOne()"
    echo "- Delete '$1' couchbase user"
    checkCouchbaseEnv
    displayCouchbaseTabInfoBlock
    echo "  - user : $1"
    deleteCouchbaseBucket $1
}


#######################################
# dispatch across sub-command delete-user
#######################################
function dispatcherDeleteUser {
    displayStartupMessage
    case $2 in
        "") 
            displayCommandMessage $1 close
            doDeleteUserGlobal; 
            displayEndMessage "deleting all mysql and couchbase user(s)" ;;
        mysql)
            displayCommandMessage $1
            displayDbtypeMessage $2 close;
            case $3 in
                "")
                    doDeleteUserMysqlAll; 
                    displayEndMessage "deleting all mysql user(s)" ;;
                *)
                    doDeleteUserMysqlOne $3; 
                    displayEndMessage "deleting mysql user $3" ;;
            esac
        ;;
        couchbase)  
            displayCommandMessage $1
            displayDbtypeMessage $2 close;
            case $3 in
                "")
                    doDeleteUserCouchbaseAll; 
                    displayEndMessage "deleting all couchbase user(s)" ;;
                *)
                    doDeleteUserCouchbaseOne $3; 
                    displayEndMessage "deleting couchbase user $3" ;;
            esac
        ;;
        help|--help)
            displayCommandMessage help close
            displayDeleteUserHelp
        ;;
        *)
            displayCommandMessage unknown close
            displayDeleteUserHelp $2 
        ;;
    esac
}










