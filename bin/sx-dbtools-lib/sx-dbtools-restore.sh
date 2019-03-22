#!/bin/bash

#######################################
# Display restore help message
#######################################
function displayRestoreHelp {
if  [ ! "$1" == ""  ]; then
    displayErrorMessage "database type '$1' IS NOT SUPPORTED"
fi
cat <<EOF
Restore one or all type of database

Usage:
  sx-dbtools restore [database-type]

Available Database type:
  mysql        Restore all mysql databases
  couchbase    Restore all couchbase buckets

Examples:
  # Restore all databases
  sx-dbtools restore
  # Restore only mysql databases
  sx-dbtools restore mysql
  # Restore only couchbase buckets
  sx-dbtools restore couchbase
EOF
exit 0;
}

#######################################
# Execute restore for all databases
#######################################
function doRestoreGlobal {
    displayDebugMessage "restore : doRestoreGlobal()"
    checkMysqlEnv
    displayMysqlTabInfoBlock
    echo "  - database(s) : $MYSQL_DATABASE"
    echo "  - source : $SXDBTOOLS_BACKUP_DIR"
    checkCouchbaseEnv
    displayCouchbaseTabInfoBlock
    echo "  - bucket(s) : $COUCHBASE_BUCKET"
    echo "  - source : $SXDBTOOLS_BACKUP_DIR"
    displayNotImplementedMessage
#    doRestoreMysqlAll
#    doRestoreCouchbaseAll
}


#######################################
# Execute restore for all mysql databases
#######################################
function doRestoreMysqlAll {
    displayDebugMessage "restore : doRestoreMysqlAll()"
    echo "- Restore all mysql database"
    checkMysqlEnv
    displayMysqlTabInfoBlock
    echo "  - database(s) : $MYSQL_DATABASE"
    echo "  - source : $SXDBTOOLS_BACKUP_DIR"
    displayNotImplementedMessage
}

#######################################
# Execute restore for one mysql database
#######################################
function doRestoreMysqlOne {
    displayDebugMessage "restore : doRestoreMysqlOne()"
    echo "- Restore '$1' mysql database"
    checkMysqlEnv
    displayMysqlTabInfoBlock
    echo "  - database(s) : $1"
    echo "  - source : $SXDBTOOLS_BACKUP_DIR"
    displayNotImplementedMessage
}


#######################################
# Execute restore for all couchbase buckets
#######################################
function doRestoreCouchbaseAll {
    displayDebugMessage "restore : doRestoreCouchbaseAll()"
    echo "- Restore all couchbase buckets"
    checkCouchbaseEnv
    displayCouchbaseTabInfoBlock
    echo "  - bucket(s) : $COUCHBASE_BUCKET"
    echo "  - source : $SXDBTOOLS_BACKUP_DIR"
    displayNotImplementedMessage
}

#######################################
# Execute restore for one couchbase bucket
#######################################
function doRestoreCouchbaseOne {
    displayDebugMessage "restore : doRestoreCouchbaseOne()"
    echo "- Restore '$1' couchbase bucket"
    checkCouchbaseEnv
    displayCouchbaseTabInfoBlock
    echo "  - bucket(s) : $1"
    echo "  - source : $SXDBTOOLS_BACKUP_DIR"
    displayNotImplementedMessage
}


#######################################
# dispatch across sub-command restore
#######################################
function dispatcherRestore {
    displayStartupMessage
    case $2 in
        "") 
            displayCommandMessage $1 close
            doRestoreGlobal; 
            displayEndMessage "restoring all mysql and couchbase database(s)" ;;
        mysql)
            displayCommandMessage $1
            displayDbtypeMessage $2 close;
            case $3 in
                "")
                    doRestoreMysqlAll; 
                    displayEndMessage "restoring all mysql database(s)" ;;
                *)
                    doRestoreMysqlOne $3; 
                    displayEndMessage "restoring mysql database $3" ;;
            esac
        ;;
        couchbase)  
            displayCommandMessage $1
            displayDbtypeMessage $2 close;
            case $3 in
                "")
                    doRestoreCouchbaseAll; 
                    displayEndMessage "restoring all couchbase bucket(s)" ;;
                *)
                    doRestoreCouchbaseOne $3; 
                    displayEndMessage "restoring couchbase bucket $3" ;;
            esac
        ;;
        help|--help)
            displayCommandMessage help close
            displayRestoreHelp
        ;;
        *)
            displayCommandMessage unknown close
            displayRestoreHelp $2 
        ;;
    esac
}










