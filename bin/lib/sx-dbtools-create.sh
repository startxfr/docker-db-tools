#!/bin/bash

#######################################
# Display create help message
#######################################
function displayCreateHelp {
if  [ ! "$1" == ""  ]; then
    displayErrorMessage "database type '$1' IS NOT SUPPORTED"
fi
cat <<EOF
Create database(s), user(s) and data for one or all type of database(s)

Usage:
  sx-dbtools create [database-type]

Available Database type:
  mysql        Create all mysql database(s), user(s) and data
  couchbase    Create all couchbase database(s), user(s) and data

Examples:
  # Create all database(s), user(s) and data
  sx-dbtools create
  # Create only mysql database(s), user(s) and data
  sx-dbtools create mysql
  # Create only couchbase database(s), user(s) and data
  sx-dbtools create couchbase
EOF
exit 0;
}

#######################################
# Execute create for all database(s), user(s) and data
#######################################
function doCreateGlobal {
    displayCommandMessage create close
    doCreateMysqlAll
    doCreateCouchbaseAll
}


#######################################
# Execute create for all mysql udatabase(s), user(s) and data
#######################################
function doCreateMysqlAll {
    echo "- Create all mysql database(s), user(s) and data"
    checkMysqlEnv
    displayMysqlTabInfoBlock
    echo "  - user(s) : $MYSQL_USERS"
    createMysqls
}


#######################################
# Execute create for all couchbase user(s)
#######################################
function doCreateCouchbaseAll {
    echo "- Create all couchbase database(s), user(s) and data"
    checkCouchbaseEnv
    displayCouchbaseTabInfoBlock
    echo "  - user(s) : $COUCHBASE_USERS"
    createCouchbaseBuckets
}


#######################################
# dispatch across sub-command create
#######################################
function dispatcherCreate {
    displayStartupMessage
    displayCommandMessage $1
    case $2 in
        "") 
            doCreateGlobal; 
            displayEndMessage "creating all mysql and couchbase database(s), user(s) and data" ;;
        mysql)
            displayDbtypeMessage $2 close;
            case $3 in
                "")
                    doCreateMysqlAll; 
                    displayEndMessage "creating all mysql database(s), user(s) and data" ;;
                *)
                    displayCreateHelp ;;
            esac
        ;;
        couchbase)  
            displayDbtypeMessage $2 close;
            case $3 in
                "")
                    doCreateCouchbaseAll; 
                    displayEndMessage "creating all couchbase database(s), user(s) and data" ;;
                *)
                    displayCreateHelp ;;
            esac
        ;;
        help|--help)
            displayCreateHelp 
        ;;
        *)
            displayCreateHelp $2 
        ;;
    esac
}










