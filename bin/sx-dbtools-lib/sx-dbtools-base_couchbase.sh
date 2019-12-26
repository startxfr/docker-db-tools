#!/bin/bash


#######################################
# Display small repetitive information in tabulated information block
#######################################
function displayCouchbaseTabInfoBlock {
    echo "  - server : $COUCHBASE_HOST"
    echo "  - bucket(s) : $COUCHBASE_BUCKET"
    if [ `isDebug` == "true" ]; then
        echo "  - couchbase admin : $COUCHBASE_ADMIN"
        echo "  - couchbase user(s) : $COUCHBASE_USERS"
    fi 
}


function checkCouchbaseEnv {
    displayDebugMessage "base_couchbase : checkCouchbaseEnv()"
    if [ ! -z "$DBC_PORT_8091_TCP_START" ]; then
        displayDebugMessage "couchbase linked container labeled 'dbc' via docker"
        if [ -z "$DBC_PORT_8091_TCP_ADDR" ]; then
            displayErrorMessage "Need to expose port 8091 from your couchbase container"
            exit 128;
        fi 
        COUCHBASE_HOST="$DBC_PORT_8091_TCP_ADDR"
        COUCHBASE_PORT="$DBC_PORT_8091_TCP_PORT_START"
        displayDebugMessage "couchbase host set to $COUCHBASE_HOST"
    elif [ ! -z "$DBC_SERVICE_HOST" ]; then
        displayDebugMessage "couchbase linked container labeled 'dbc' via kubernetes"
        if [ -z "$DBC_PORT_8091_TCP_PORT" ]; then
            displayErrorMessage "Need to expose port 8091 from your couchbase container"
            exit 128;
        fi 
        COUCHBASE_HOST="$DBC_SERVICE_HOST"
        COUCHBASE_PORT="$DBC_PORT_8091_TCP_PORT"
        displayDebugMessage "couchbase host set to $COUCHBASE_HOST"
    else
        displayDebugMessage "No couchbase linked container labeled 'dbc'"
        if [ -z "$COUCHBASE_HOST" ]; then
            displayErrorMessage "Need to set COUCHBASE_HOST"
            exit 128;
        fi 
        displayDebugMessage "couchbase host set to $COUCHBASE_HOST"
        if [ -z "$COUCHBASE_PORT" ]; then
            COUCHBASE_PORT=8091
        fi 
    fi
    if [ -z "$COUCHBASE_BUCKET" ]; then
        displayErrorMessage "Need to set COUCHBASE_BUCKET"
        exit 128;
    fi
    if [ -z "$COUCHBASE_ADMIN" ]; then
        displayErrorMessage "Need to set COUCHBASE_ADMIN"
        exit 128;
    else
        if [ -z "$COUCHBASE_PASSWORD" ]; then
            set -f; IFS=':'; set -- $COUCHBASE_ADMIN
            COUCHBASE_ADMIN=$1; PWD=$2; set +f; unset IFS
            export RANDFILE=/tmp/.rnd
            if [ -z "$PWD" ]; then
                COUCHBASE_GENERATED="true"
                COUCHBASE_PASSWORD=$(openssl rand -base64 32 | sha256sum | base64 | head -c 16 ; echo)
            else 
                COUCHBASE_PASSWORD=$PWD
            fi
            displayDebugMessage "couchbase admin user set to $COUCHBASE_ADMIN"
            displayDebugMessage "couchbase admin password set to $COUCHBASE_PASSWORD"
        fi
    fi 
    if [ -z "$COUCHBASE_DUMP_DIR" ]; then
        displayErrorMessage "Need to set COUCHBASE_DUMP_DIR"
        exit 128;
    fi 
    mkdir -p $COUCHBASE_DUMP_DIR
    if checkCouchbaseIsNotInitialized; then
        echo "  - initialize cluster $COUCHBASE_HOST"
        initializeCouchbase
    fi
}

function dumpCouchbaseBucketAll {
    displayDebugMessage "base_couchbase : dumpCouchbaseBucketAll()"
    if [ ! -z "$COUCHBASE_BUCKET" ]; then
        for BUCKET in $(echo $COUCHBASE_BUCKET | tr "," "\n")
        do
            echo "  - dump data $BUCKET > $BUCKET.$COUCHBASE_DUMP_DATAFILE"
            runDumpCouchbaseBucket $BUCKET
        done
    fi 
}

function dumpCouchbaseBucketOne {
    displayDebugMessage "base_couchbase : dumpCouchbaseBucketOne($1)"
    echo "  - dump data $1 > $1.$COUCHBASE_DUMP_DATAFILE"
    runDumpCouchbaseBucket $1
}

function runDumpCouchbaseBucket {
    displayDebugMessage "base_couchbase : runDumpCouchbaseBucket($1)"
    if cbexport json \
    -f list \
    -c couchbase://$COUCHBASE_HOST:$COUCHBASE_PORT \
    -o $COUCHBASE_DUMP_DIR/$1.$COUCHBASE_DUMP_DATAFILE \
    -b $1 \
    -u $COUCHBASE_ADMIN \
    -p $COUCHBASE_PASSWORD \
    --include-key _id; then
        displayDebugMessage "bucket $1 saved in $COUCHBASE_DUMP_DIR/$1.$COUCHBASE_DUMP_DATAFILE"
    else
        displayErrorMessage "Could not dump bucket $1 into $COUCHBASE_DUMP_DIR"
    fi;
}

function checkCouchbaseIsNotInitialized {
    RESULT=`couchbase-cli bucket-list -c couchbase://$COUCHBASE_HOST:$COUCHBASE_PORT -u $COUCHBASE_ADMIN -p $COUCHBASE_PASSWORD`
    if [[ $RESULT == *"Cluster is not initialized"* ]]; then
        return 0; # no error
    else
        return 1; # error code
    fi
}

function checkCouchbaseBucketsExist {
    if [ ! -z "$COUCHBASE_BUCKET" ]; then
        for BUCKET in $(echo $COUCHBASE_BUCKET | tr "," "\n")
        do
            echo $(runCheckCouchbaseBucketExist $BUCKET)
            return;
        done
    fi 
}

function checkCouchbaseBucketExist {
    if [ ! -z "$1" ]; then
        echo $(runCheckCouchbaseBucketExist $1)
        return;
    fi 
}

function runCheckCouchbaseBucketExist {
    RESULT=`couchbase-cli bucket-list -c couchbase://$COUCHBASE_HOST:$COUCHBASE_PORT -u $COUCHBASE_ADMIN -p $COUCHBASE_PASSWORD | grep $1`
    if [ "$RESULT" == "$1" ]; then
        return 0; # no error
    else
        return 1; # error code
    fi
}

function initializeCouchbase {
    displayDebugMessage "base_couchbase : initializeCouchbase()"
    couchbase-cli cluster-init \
    -c couchbase://$COUCHBASE_HOST:$COUCHBASE_PORT \
    --cluster-username $COUCHBASE_ADMIN \
    --cluster-password $COUCHBASE_PASSWORD \
    --cluster-ramsize 1000 \
    --cluster-index-ramsize 300 \
    --cluster-name $COUCHBASE_HOST \
    --services data,index,query \
    --index-storage-setting memopt
    echo "- cluster $COUCHBASE_HOST initialized"
    if [ ! -z "$COUCHBASE_GENERATED" ]; then
        echo "  - user : $COUCHBASE_ADMIN created"
        echo "  - with pwd : [generated]"
        echo "  - password : $COUCHBASE_PASSWORD (! NOTICE : display only once)"
    else 
        echo "  - user : $COUCHBASE_ADMIN created"
        echo "  - with pwd : [user given]"
    fi
}

function createCouchbaseBuckets {
    displayDebugMessage "base_couchbase : createCouchbaseBuckets()"
    if [ ! -z "$COUCHBASE_BUCKET" ]; then
        for BUCKET in $(echo $COUCHBASE_BUCKET | tr "," "\n")
        do
            echo "  - create bucket $1"
            runCreateCouchbaseBucket $BUCKET
        done
    fi 
}

function createCouchbaseBucket {
    displayDebugMessage "base_couchbase : createCouchbaseBucket($1)"
    if [ ! -z "$1" ]; then
        echo "  - create bucket $1"
        runCreateCouchbaseBucket $1
    fi 
}

function runCreateCouchbaseBucket {
    displayDebugMessage "base_couchbase : runCreateCouchbaseBucket($1)"
    if couchbase-cli bucket-create \
    -c couchbase://$COUCHBASE_HOST:$COUCHBASE_PORT \
    -u $COUCHBASE_ADMIN \
    -p $COUCHBASE_PASSWORD \
    --bucket $1 \
    --bucket-type couchbase \
    --bucket-ramsize 200 \
    --wait; then
        displayDebugMessage "bucket : $1 created"
    else
        displayErrorMessage "Could not create bucket $1"
    fi;
}

function createCouchbaseUsers {
    displayDebugMessage "base_couchbase : createCouchbaseUsers($1,$2)"
    if [ ! -z "$COUCHBASE_USERS" ]; then
        for userInfo in $(echo $COUCHBASE_USERS | tr "," "\n")
        do
            set -f; IFS=':'; set -- $userInfo
            USER=$1; PWD=$2; set +f; unset IFS
            createCouchbaseUser $USER $PWD
        done
    fi 
    if [[ -r $COUCHBASE_DUMP_DIR/USER ]]; then
        for userInfo in $(cat $COUCHBASE_DUMP_DIR/USER | tr "," "\n")
        do
            set -f; IFS=':'; set -- $userInfo
            USER=$1; PWD=$2; set +f; unset IFS
            createCouchbaseUser $USER $PWD
        done
    fi 
}

function createCouchbaseUser {
    displayDebugMessage "base_couchbase : createCouchbaseUser($1,$2)"
    if [[ ! -z "$1" ]]; then
        runCreateCouchbaseUser $1 $2
    fi 
}

function runCreateCouchbaseUser {
    displayDebugMessage "base_couchbase : runCreateCouchbaseUser($1,$2)"
    USER=$1
    PWD=$2
    export RANDFILE=/tmp/.rnd
    echo "  - create couchbase user $USER"
    if [ -z "$PWD" ]; then
        PWD=$(openssl rand -base64 32 | sha256sum | base64 | head -c 16 ; echo)
        echo "    - with pwd    : [generated]"
        echo "    - password    : $PWD (! NOTICE : display only once)"
    else 
        echo "    - with pwd    : [user given]"
    fi
    if couchbase-cli user-manage \
    -c couchbase://$COUCHBASE_HOST:$COUCHBASE_PORT \
    -u $COUCHBASE_ADMIN \
    -p $COUCHBASE_PASSWORD \
    --set --auth-domain local \
    --rbac-username $USER \
    --rbac-password $PWD \
    --rbac-name $USER \
    --roles bucket_admin[*] ; then
        displayDebugMessage "user : $USER created"
    else
        displayErrorMessage "Could not create user $USER"
    fi;
}

function importCouchbaseBuckets {
    displayDebugMessage "base_couchbase : importCouchbaseBuckets()"
    if [ ! -z "$COUCHBASE_BUCKET" ]; then
        for BUCKET in $(echo $COUCHBASE_BUCKET | tr "," "\n")
        do
            runImportCouchbaseBucketData $BUCKET
        done
    fi 
}

function importCouchbaseBucket {
    displayDebugMessage "base_couchbase : importCouchbaseBucket($1)"
    if [ ! -z "$1" ]; then
        runImportCouchbaseBucketData $1
    fi 
}

function runImportCouchbaseBucketData {
    displayDebugMessage "base_couchbase : runImportCouchbaseBucketData($1)"
    if [[ -r $COUCHBASE_DUMP_DIR/$1.$COUCHBASE_DUMP_DATAFILE ]]; then
        FILE=$1.$COUCHBASE_DUMP_DATAFILE
    elif [[ -r $COUCHBASE_DUMP_DIR/$COUCHBASE_DUMP_DATAFILE ]]; then
        FILE=$COUCHBASE_DUMP_DATAFILE
    fi 
    echo "  - load data $FILE > $1"
    if cbimport json \
    -f list \
    -c couchbase://$COUCHBASE_HOST:$COUCHBASE_PORT \
    -d file://$COUCHBASE_DUMP_DIR/$FILE \
    -b $1 \
    -u $COUCHBASE_ADMIN \
    -p $COUCHBASE_PASSWORD \
    --generate-key %_id%; then
        displayDebugMessage "data file: $FILE loaded in bucket $1"
    else
        displayErrorMessage "Could not load data file $FILE in bucket $1"
    fi;
}

function deleteCouchbaseBuckets {
    displayDebugMessage "base_couchbase : deleteCouchbaseBuckets()"
    if [ ! -z "$COUCHBASE_BUCKET" ]; then
        for BUCKET in $(echo $COUCHBASE_BUCKET | tr "," "\n")
        do
            echo "  - delete bucket $1"
            runDeleteCouchbaseBucket $BUCKET
        done
    fi 
}

function deleteCouchbaseBucket {
    displayDebugMessage "base_couchbase : deleteCouchbaseBucket($1)"
    if [ ! -z "$1" ]; then
        echo "  - delete bucket $1"
        runDeleteCouchbaseBucket $1
    fi 
}

function runDeleteCouchbaseBucket {
    displayDebugMessage "base_couchbase : runDeleteCouchbaseBucket($1)"
    if couchbase-cli bucket-delete \
    -c couchbase://$COUCHBASE_HOST:$COUCHBASE_PORT \
    -u $COUCHBASE_ADMIN \
    -p $COUCHBASE_PASSWORD \
    --bucket $1; then
        displayDebugMessage "bucket : $1 deleted"
    else
        displayErrorMessage "Could not delete bucket $1"
    fi;
}

function deleteCouchbaseUsers {
    displayDebugMessage "base_couchbase : deleteCouchbaseUsers()"
    if [ ! -z "$COUCHBASE_USERS" ]; then
        for userInfo in $(echo $COUCHBASE_USERS | tr "," "\n")
        do
            set -f; IFS=':'; set -- $userInfo
            USER=$1; PWD=$2; set +f; unset IFS
            echo "  - delete couchbase user $USER"
            runDeleteCouchbaseUser $USER
        done
    fi 
    if [[ -r $COUCHBASE_DUMP_DIR/USER ]]; then
        for userInfo in $(cat $COUCHBASE_DUMP_DIR/USER | tr "," "\n")
        do
            set -f; IFS=':'; set -- $userInfo
            USER=$1; PWD=$2; set +f; unset IFS
            runDeleteCouchbaseUser $USER
        done
    fi 
}

function deleteCouchbaseUser {
    displayDebugMessage "base_couchbase : deleteCouchbaseUser()"
    if [ ! -z "$1" ]; then
        echo "  - delete couchbase user $1"
        runDeleteCouchbaseUser $1
    fi 
}

function runDeleteCouchbaseUser {
    displayDebugMessage "base_couchbase : runDeleteCouchbaseUser($1)"
    if couchbase-cli user-manage \
    -c couchbase://$COUCHBASE_HOST:$COUCHBASE_PORT \
    -u $COUCHBASE_ADMIN \
    -p $COUCHBASE_PASSWORD \
    --delete --auth-domain local \
    --rbac-username $1 ; then
        displayDebugMessage "user : $1 deleted"
    else
        displayErrorMessage "Could not deleted user $1"
    fi;
}
