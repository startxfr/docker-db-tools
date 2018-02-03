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
    displayCommandMessage backup close
    doBackupMysqlAll
    doBackupCouchbaseAll
}


#######################################
# Execute backup for all mysql databases
#######################################
function doBackupMysqlAll {
    echo "- Backup all mysql database"
    checkMysqlEnv
    if checkMysqlDatabasesExist; then
        displayMysqlTabInfoBlock
        echo "  - database(s) : $MYSQL_DATABASE"
        echo "  - destination : $MYSQL_DUMP_DIR"
        backupMysqlDatabaseAll
    else
        echo "  - mysql database(s) $MYSQL_DATABASE doesn't exist. Nothing to backup"
    fi
}

#######################################
# Execute backup for one mysql database
#######################################
function doBackupMysqlOne {
    echo "- Backup '$1' mysql database"
    checkMysqlEnv
    if checkMysqlDatabaseExist $1; then
        displayMysqlTabInfoBlock
        echo "  - database : $1"
        echo "  - destination : $MYSQL_DUMP_DIR"
        backupMysqlDatabaseOne $1
    else
        echo "  - mysql database $1 doesn't exist. Nothing to backup"
    fi
}


#######################################
# Execute backup for all couchbase buckets
#######################################
function doBackupCouchbaseAll {
    echo "- Backup all couchbase buckets"
    checkCouchbaseEnv
    if checkCouchbaseIsNotInitialized; then
        echo "  - Couchbase host $COUCHBASE_HOST is not initialized. Nothing to backup"
    elif $(checkCouchbaseBucketsExist); then
        displayCouchbaseTabInfoBlock
        echo "  - bucket(s) : $COUCHBASE_BUCKET"
        echo "  - destination : $COUCHBASE_DUMP_DIR"
        backupCouchbaseBucketAll
    else
        echo "  - Couchbase bucket $COUCHBASE_BUCKET doesn't exist. Nothing to backup"
    fi
}

#######################################
# Execute backup for one couchbase bucket
#######################################
function doBackupCouchbaseOne {
    echo "- Backup '$1' couchbase bucket"
    checkCouchbaseEnv
    if checkCouchbaseIsNotInitialized; then
        echo "  - Couchbase host $COUCHBASE_HOST is not initialized. Nothing to backup"
    elif $(checkCouchbaseBucketsExist); then
        displayCouchbaseTabInfoBlock
        echo "  - bucket : $1"
        echo "  - destination : $COUCHBASE_DUMP_DIR"
        backupCouchbaseBucketOne $1
    else
        echo "  - Couchbase bucket $COUCHBASE_BUCKET doesn't exist. Nothing to backup"
    fi
}


#######################################
# dispatch across sub-command backup
#######################################
function dispatcherBackup {
    displayStartupMessage
    displayCommandMessage $1
    case $2 in
        "") 
            doBackupGlobal; 
            displayEndMessage "backuping all mysql and couchbase database(s)" ;;
        mysql)
            displayDbtypeMessage $2 close;
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
            displayBackupHelp
        ;;
        *)
            displayBackupHelp $2 
        ;;
    esac
}










