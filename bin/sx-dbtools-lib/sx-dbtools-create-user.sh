#!/bin/bash

#######################################
# Display create-user help message
#######################################
function displayCreateUserHelp {
if  [ ! "$1" == ""  ]; then
    displayErrorMessage "database type '$1' IS NOT SUPPORTED"
fi
cat <<EOF
Create user(s) for one or all type of database

Usage:
  sx-dbtools create-user [database-type]

Available Database type:
  mysql        Create all mysql user(s)
  couchbase    Create all couchbase user(s)

Examples:
  # Create all database(s) user(s)
  sx-dbtools create-user
  # Create only mysql user(s)
  sx-dbtools create-user mysql
  # Create only couchbase user(s)
  sx-dbtools create-user couchbase
EOF
exit 0;
}

#######################################
# Execute create-user for all database(s) user(s)
#######################################
function doCreateUserGlobal {
    doCreateUserMysqlAll
    doCreateUserCouchbaseAll
}


#######################################
# Execute create-user for all mysql user(s)
#######################################
function doCreateUserMysqlAll {
    echo "- Create all mysql user(s)"
    checkMysqlEnv
    displayMysqlTabInfoBlock
    echo "  - user(s) : $MYSQL_USERS"
    createMysqlUsers
}

#######################################
# Execute create-user for one mysql user
#######################################
function doCreateUserMysqlOne {
    echo "- Create '$1' mysql user"
    checkMysqlEnv
    displayMysqlTabInfoBlock
    echo "  - user : $1"
    createMysqlUser $1 $2
}


#######################################
# Execute create-user for all couchbase user(s)
#######################################
function doCreateUserCouchbaseAll {
    echo "- Create all couchbase user(s)"
    checkCouchbaseEnv
    displayCouchbaseTabInfoBlock
    echo "  - user(s) : $COUCHBASE_USERS"
    createCouchbaseUsers
}

#######################################
# Execute create-user for one couchbase user
#######################################
function doCreateUserCouchbaseOne {
    echo "- Create '$1' couchbase user"
    checkCouchbaseEnv
    displayCouchbaseTabInfoBlock
    echo "  - bucket : $1"
    createCouchbaseUser $1
}


#######################################
# dispatch across sub-command create-user
#######################################
function dispatcherCreateUser {
    displayStartupMessage
    case $2 in
        "") 
            displayCommandMessage $1 close
            doCreateUserGlobal; 
            displayEndMessage "creating all mysql and couchbase user(s)" ;;
        mysql)
            displayCommandMessage $1
            displayDbtypeMessage $2 close;
            case $3 in
                "")
                    doCreateUserMysqlAll; 
                    displayEndMessage "creating all mysql user(s)" ;;
                *)
                    doCreateUserMysqlOne $3; 
                    displayEndMessage "creating mysql user $3" ;;
            esac
        ;;
        couchbase)  
            displayCommandMessage $1
            displayDbtypeMessage $2 close;
            case $3 in
                "")
                    doCreateUserCouchbaseAll; 
                    displayEndMessage "creating all couchbase user(s)" ;;
                *)
                    doCreateUserCouchbaseOne $3; 
                    displayEndMessage "creating couchbase user $3" ;;
            esac
        ;;
        help|--help)
            displayCommandMessage help close
            displayCreateUserHelp
        ;;
        *)
            displayCommandMessage unknown close
            displayCreateUserHelp $2 
        ;;
    esac
}










