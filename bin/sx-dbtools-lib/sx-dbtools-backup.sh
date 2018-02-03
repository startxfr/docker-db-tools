#!/bin/bash

#######################################
# Display backup help message
#######################################
function displayBackupHelp {
if  [ ! "$1" == ""  ]; then
    displayErrorMessage "database type '$1' IS NOT SUPPORTED"
fi
cat <<EOF
Backup one or all type of database

Usage:
  sx-dbtools backup [database-type]

Available Database type:
  mysql        Backup all mysql databases
  couchbase    Backup all couchbase buckets

Examples:
  # Backup all databases
  sx-dbtools backup
  # Backup only mysql databases
  sx-dbtools backup mysql
  # Backup only couchbase buckets
  sx-dbtools backup couchbase
EOF
exit 0;
}

#######################################
# Execute backup for all databases
#######################################
function doBackupGlobal {
    echo "- Backup all database"
    checkMysqlEnv
    displayMysqlTabInfoBlock
    echo "  - database(s) : $MYSQL_DATABASE"
    echo "  - destination : $SXDBTOOLS_BACKUP_DIR"
    checkCouchbaseEnv
    displayCouchbaseTabInfoBlock
    echo "  - bucket(s) : $COUCHBASE_BUCKET"
    echo "  - destination : $SXDBTOOLS_BACKUP_DIR"
    displayNotImplementedMessage
#    doBackupMysqlAll
#    doBackupCouchbaseAll
}


#######################################
# Execute backup for all mysql databases
#######################################
function doBackupMysqlAll {
    echo "- Backup all mysql database"
    checkMysqlEnv
    displayMysqlTabInfoBlock
    echo "  - database(s) : $MYSQL_DATABASE"
    echo "  - destination : $SXDBTOOLS_BACKUP_DIR"
    displayNotImplementedMessage
}

#######################################
# Execute backup for one mysql database
#######################################
function doBackupMysqlOne {
    echo "- Backup '$1' mysql database"
    checkMysqlEnv
    displayMysqlTabInfoBlock
    echo "  - database(s) : $1"
    echo "  - destination : $SXDBTOOLS_BACKUP_DIR"
    displayNotImplementedMessage
}


#######################################
# Execute backup for all couchbase buckets
#######################################
function doBackupCouchbaseAll {
    echo "- Backup all couchbase buckets"
    checkCouchbaseEnv
    displayCouchbaseTabInfoBlock
    echo "  - bucket(s) : $COUCHBASE_BUCKET"
    echo "  - destination : $SXDBTOOLS_BACKUP_DIR"
    displayNotImplementedMessage
}

#######################################
# Execute backup for one couchbase bucket
#######################################
function doBackupCouchbaseOne {
    echo "- Backup '$1' couchbase bucket"
    checkCouchbaseEnv
    displayCouchbaseTabInfoBlock
    echo "  - bucket(s) : $1"
    echo "  - destination : $SXDBTOOLS_BACKUP_DIR"
    displayNotImplementedMessage
}


#######################################
# dispatch across sub-command backup
#######################################
function dispatcherBackup {
    displayStartupMessage
    case $2 in
        "") 
            displayCommandMessage $1 close
            doBackupGlobal; 
            displayEndMessage "backuping all mysql and couchbase database(s)" ;;
        mysql)
            displayCommandMessage $1
            displayDbtypeMessage $2 close
            case $3 in
                "")
                    doBackupMysqlAll; 
                    displayEndMessage "backuping all mysql database(s)" ;;
                *)
                    doBackupMysqlOne $3; 
                    displayEndMessage "backuping mysql database $3" ;;
            esac
        ;;
        couchbase)  
            displayCommandMessage $1
            displayDbtypeMessage $2 close;
            case $3 in
                "")
                    doBackupCouchbaseAll; 
                    displayEndMessage "backuping all couchbase bucket(s)" ;;
                *)
                    doBackupCouchbaseOne $3; 
                    displayEndMessage "backuping couchbase bucket $3" ;;
            esac
        ;;
        help|--help)
            displayCommandMessage help close
            displayBackupHelp
        ;;
        *)
            displayCommandMessage unknown close
            displayBackupHelp $2 
        ;;
    esac
}










