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
    doCreateMysqlAll
    doCreateCouchbaseAll
}


#######################################
# Execute create for all mysql database(s), user(s) and data
#######################################
function doCreateMysqlAll {
    echo "- Create all mysql database(s), user(s) and data"
    checkMysqlEnv
    displayMysqlTabInfoBlock
    echo "  - database(s) : $MYSQL_DATABASE"
    echo "  - user(s) : $MYSQL_USERS"
    echo "  - source : $MYSQL_DUMP_DIR"
    createMysqlDatabases
    createMysqlUsers
    importMysqlDatabases
}


#######################################
# Execute create for all couchbase bucket(s), user(s) and data
#######################################
function doCreateCouchbaseAll {
    echo "- Create all couchbase bucket(s), user(s) and data"
    checkCouchbaseEnv
    displayCouchbaseTabInfoBlock
    echo "  - bucket(s) : $COUCHBASE_BUCKET"
    echo "  - user(s) : $COUCHBASE_USERS"
    echo "  - source : $COUCHBASE_DUMP_DIR"
    createCouchbaseBuckets
    createCouchbaseUsers
    importCouchbaseBuckets
}


#######################################
# dispatch across sub-command create
#######################################
function dispatcherCreate {
    displayStartupMessage
    case $2 in
        "") 
            displayCommandMessage $1 close
            doCreateGlobal; 
            displayEndMessage "creating all mysql and couchbase database(s), user(s) and data" ;;
        mysql)
            displayCommandMessage $1
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
            displayCommandMessage $1
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
            displayCommandMessage help close
            displayCreateHelp 
        ;;
        *)
            displayCommandMessage unknown close
            displayCreateHelp $2 
        ;;
    esac
}










