#!/bin/bash
OS=`cat /etc/os-release | grep "PRETTY_NAME" | sed 's/PRETTY_NAME=//g' | sed 's/["]//g' | awk '{print $1}'`


#######################################
# Display debug message
#######################################
function isDebug {
    if [ ! -z "$SXDBTOOLS_DEBUG" ]; then
        if [[ $SXDBTOOLS_DEBUG == *"true"* ]]; then
            echo "true";
            return;
        fi 
    fi 
    echo "false";
}

#######################################
# Display debug message
#######################################
function displayDebugMessage {
    if [ `isDebug` == "true" ]; then
            echo "DEBUG: " $@
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
# Display not implemented message
#######################################
function displayNotImplementedMessage {
    echo ""
    echo "! This section is not yet implemented"
    echo "! see https://github.com/startxfr/docker-db-tools/"
    echo "! for more informations on next releases"
    echo ""
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

- Global Commands:
  create           Create user(s) + database(s) + data
  delete           Delete user(s) + database(s) + data
  recreate         Delete and create user(s) + database(s) + data

- Data Commands:
  dump             Dump database(s) in dump directory
  import           import database(s) from dump directory
  create-data      alias of import command

- Backup / Restore Commands:
  backup           Backup database(s) in backup directory
  restore          Restore database(s) in backup directory

- User management Commands:
  create-user      Create database(s) user(s)
  delete-user      Delete database(s) user(s)
  recreate-user    Delete and create database(s) user(s)

- Database Commands:
  create-db        Create database(s)
  delete-db        Delete database(s)
  recreate-db      Delete and create database(s)

- sx-dbtools Commands:
  usage            this message
  <cmd> help       display information about a command
  info             give information about the running sx-dbtools
  version          give the version of the running sx_dbtools
  daemon           execute the container as a daemon (keep alive)
  cmd              execute a command inside the container

Examples:
  # Get this message
  sx-dbtools usage
  # Dump all databases
  sx-dbtools dump

EOF
exit 0;
}



#######################################
# Display general welcome message
#######################################
function displayWelcome {
cat <<EOF
sx-dbtools v$SXDBTOOLS_VERSION $HOSTNAME ($OS)

Welcome to the sx-dbtools. If you see this message, you have
probably run this container without arguments. You can run the
following command to perform actions

  create           Create user(s) + database(s) + data
  delete           Delete user(s) + database(s) + data
  recreate         Delete and create user(s) + database(s) + data
  dump             Dump database(s) in dump directory
  import           import database(s) from dump directory
  create-data      alias of import command
  backup           Backup database(s) in backup directory
  restore          Restore database(s) in backup directory
  create-user      Create database(s) user(s)
  delete-user      Delete database(s) user(s)
  recreate-user    Delete and create database(s) user(s)
  create-db        Create database(s)
  delete-db        Delete database(s)
  recreate-db      Delete and create database(s)
  usage            this message
  <cmd> help       display information about a command
  info             give information about the running sx-dbtools
  version          give the version of the running sx_dbtools
  daemon           execute the container as a daemon (keep alive)
  cmd              execute a command inside the container

EOF
exit 0;
}

#######################################
# Display sx-dbtools information
#######################################
function displayInformation {
echo "sx-dbtools version : $SXDBTOOLS_VERSION"
echo "sx-dbtools container : $HOSTNAME"
echo "sx-dbtools OS : $OS"
echo "mysql dump directory : $MYSQL_DUMP_DIR"
if [ `isDebug` == "true" ]; then
    echo "mysql schema file : $MYSQL_DUMP_SCHEMAFILE"
    echo "mysql data file   : $MYSQL_DUMP_DATAFILE"
fi 
echo "mysql host : $MYSQL_HOST"
echo "mysql database(s) : $MYSQL_DATABASE"
if [ `isDebug` == "true" ]; then
    echo "mysql admin       : $MYSQL_ADMIN"
    echo "mysql user(s)     : $MYSQL_USERS"
fi 
echo "couchbase dump directory : $COUCHBASE_DUMP_DIR"
if [ `isDebug` == "true" ]; then
    echo "couchbase data file: $COUCHBASE_DUMP_DATAFILE"
fi 
echo "couchbase host : $COUCHBASE_HOST"
echo "couchbase bucket(s) : $COUCHBASE_BUCKET"
if [ `isDebug` == "true" ]; then
    echo "couchbase admin   : $COUCHBASE_ADMIN"
    echo "couchbase user(s) : $COUCHBASE_USERS"
fi
exit 0;
}

#######################################
# Display sx-dbtools version
#######################################
function displayVersion {
echo $SXDBTOOLS_VERSION
if [ `isDebug` == "true" ]; then
    env
fi 
exit 0;
}

#######################################
# Display sx-dbtools command
#######################################
function displayCommand {
    if [ ! -z "$2" ]; then
        shift
        exec $@
    else
        exec cat /etc/hostname
    fi 
}

#######################################
# Display sx-dbtools daemon
#######################################
function displayDaemon {
    while true; do
        if [ `isDebug` == "true" ]; then
            echo "sx-dbtools is alive on $HOSTNAME running sx-dbtools v$SXDBTOOLS_VERSION"
        else
            echo "sx-dbtools is alive on $HOSTNAME"
        fi
        sleep 10
    done
}
