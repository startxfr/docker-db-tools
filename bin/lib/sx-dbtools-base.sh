#!/bin/bash
OS=`cat /etc/os-release | grep "PRETTY_NAME" | sed 's/PRETTY_NAME=//g' | sed 's/["]//g' | awk '{print $1}'`


#######################################
# Display debug message
#######################################
function displayDebugMessage {
    if [ ! -z "$SXDBTOOLS_DEBUG" ]; then
        if [[ $SXDBTOOLS_DEBUG == *"true"* ]]; then
            echo "DEBUG: " $@
        fi 
    fi 
}

#######################################
# Display error message
#######################################
function displayErrorMessage {
    echo ""
    echo "! ERROR !!  : " $@
    echo ""
}

#######################################
# Display end message
#######################################
function displayEndMessage {
    echo ""
    echo " END        : " $@
    exit 0;
}

#######################################
# Display startup message
#######################################
function displayStartupMessage {
    echo "==================================" 
    echo "= sx-dbtools v$SXDBTOOLS_VERSION"
    echo "= see https://github.com/startxfr/docker-db-tools/"
    echo "= --------------------------------" 
    echo "= version   : $SXDBTOOLS_VERSION"
    echo "= OS        : $OS"
    echo "= container : $HOSTNAME"
    if [ ! -z "$SXDBTOOLS_DEBUG" ]; then
        if [[ $SXDBTOOLS_DEBUG == *"true"* ]]; then
            echo "= debug     : activated"
        fi 
    fi 
}

#######################################
# Display action message
#######################################
function displayCommandMessage {
    echo "= command   : $1"
    if  [  "$2" == "close"  ]; then
        echo "==================================" 
    fi
}

#######################################
# Display sub action message
#######################################
function displaySubCommandMessage {
    echo "= subCommand: $1"
    if  [  "$2" == "close"  ]; then
        echo "==================================" 
    fi
}

#######################################
# Display sub action message
#######################################
function displayDbtypeMessage {
    echo "= db type   : $1"
    if  [  "$2" == "close"  ]; then
        echo "==================================" 
    fi
}

#######################################
# Display general usage
#######################################
function displayUsage {
cat <<EOF
sx-dbtools v$SXDBTOOLS_VERSION $HOSTNAME ($OS)

Usage:
  sx-dbtools command [database-type/sub-command]

User management Commands:
  create-user      Create database(s) user(s)
  delete-user      Delete database(s) user(s)
  recreate-user    Delete and create database(s) user(s)

Backup / Restore Commands:
  backup           Backup database(s) in backup directory
  restore          Restore database(s) in backup directory

Database Commands:
  create-db        Create database(s)
  delete-db        Delete database(s)
  recreate-db      Delete and create database(s)

Data Commands:
  dump             Dump database(s) in dump directory
  import           import database(s) from dump directory
  create-data      alias of import command

Global Commands:
  create           Create user(s) + database(s) + data
  delete           Delete user(s) + database(s) + data
  recreate         Delete and create user(s) + database(s) + data

sx-dbtools Commands:
  usage            this message
  <cmd> help       display information about a command
  info             give information about the running sx-dbtools
  version          give the version of the running sx_dbtools

Examples:
  # Get this message
  sx-dbtools usage
  # Dump all databases
  sx-dbtools dump
EOF
exit 0;
}



#######################################
# Display sx-dbtools information
#######################################
function displayInformation {
cat <<EOF
sx-dbtools version : $SXDBTOOLS_VERSION
sx-dbtools container : $HOSTNAME
sx-dbtools OS : $OS
mysql dump directory : $MYSQL_DUMP_DIR
mysql host : $MYSQL_HOST
mysql database(s) : $MYSQL_DATABASE
couchbase dump directory : $COUCHBASE_DUMP_DIR
couchbase host : $COUCHBASE_HOST
couchbase bucket(s) : $COUCHBASE_BUCKET
EOF
exit 0;
}

#######################################
# Display sx-dbtools version
#######################################
function displayVersion {
echo $SXDBTOOLS_VERSION
exit 0;
}