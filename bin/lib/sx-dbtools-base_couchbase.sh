#!/bin/bash


#######################################
# Display small repetitive information in tabulated information block
#######################################
function displayCouchbaseTabInfoBlock {
    echo "  - server : $COUCHBASE_HOST"
}


function checkCouchbaseEnv {
    if [ ! -z "$DBC_PORT_8091_TCP_START" ]; then
        if [ -z "$DBC_PORT_8091_TCP_ADDR" ]; then
            displayErrorMessage "Need to expose port 8091 from your couchbase container"
            exit 128;
        fi 
        COUCHBASE_HOST="$DBC_PORT_8091_TCP_ADDR"
        COUCHBASE_PORT="$DBC_PORT_8091_TCP_PORT_START"
    else
        displayDebugMessage "No mysql linked container labeled 'dbc'"
        if [ -z "$COUCHBASE_HOST" ]; then
            displayErrorMessage "Need to set COUCHBASE_HOST"
            exit 128;
        fi 
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
        fi
    fi 
    if [ -z "$COUCHBASE_DUMP_DIR" ]; then
        displayErrorMessage "Need to set COUCHBASE_DUMP_DIR"
        exit 128;
    fi 
    if checkCouchbaseIsNotInitialized; then
        echo "  - initialize cluster $COUCHBASE_HOST"
        initializeCouchbase
    fi
}

function dumpCouchbaseBucketAll {
    if [ ! -z "$COUCHBASE_BUCKET" ]; then
        for BUCKET in $(echo $COUCHBASE_BUCKET | tr "," "\n")
        do
            echo "  - dump data $BUCKET > $BUCKET.$COUCHBASE_DUMP_DATAFILE"
            runDumpCouchbaseBucket $BUCKET
        done
    fi 
}
function dumpCouchbaseBucketOne {
    echo "  - dump data $1 > $1.$COUCHBASE_DUMP_DATAFILE"
    runDumpCouchbaseBucket $1
}
function runDumpCouchbaseBucket {
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
            echo runCheckCouchbaseBucketExist $BUCKET
            return;
        done
    fi 
}
function checkCouchbaseBucketExist {
    if [ ! -z "$1" ]; then
        echo runCheckCouchbaseBucketExist $1
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
    if [ ! -z "$COUCHBASE_BUCKET" ]; then
        for BUCKET in $(echo $COUCHBASE_BUCKET | tr "," "\n")
        do
            echo "  - create bucket $1"
            runCreateCouchbaseBucket $BUCKET
        done
    fi 
}
function createCouchbaseBucket {
    if [ ! -z "$1" ]; then
        echo "  - create bucket $1"
        runCreateCouchbaseBucket $1
    fi 
}
function runCreateCouchbaseBucket {
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

function loadCouchbaseBucketData {
    if [ ! -z "$COUCHBASE_BUCKET" ]; then
        for BUCKET in $(echo $COUCHBASE_BUCKET | tr "," "\n")
        do
            runLoadCouchbaseBucketData $BUCKET
        done
    fi 
}
function runLoadCouchbaseBucketData {
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
    if [ ! -z "$COUCHBASE_BUCKET" ]; then
        for BUCKET in $(echo $COUCHBASE_BUCKET | tr "," "\n")
        do
            echo "  - delete bucket $1"
            runDeleteCouchbaseBucket $BUCKET
        done
    fi 
}
function deleteCouchbaseBucket {
    if [ ! -z "$1" ]; then
        echo "  - delete bucket $1"
        runDeleteCouchbaseBucket $1
    fi 
}
function runDeleteCouchbaseBucket {
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

function doCouchbaseDump { 
    checkCouchbaseEnv
    echo "=             Dumping couchbase database"
    echo "==================================" 
    echo "host        : $COUCHBASE_HOST"
    echo "bucket      : $COUCHBASE_BUCKET"
    echo "destination : $COUCHBASE_DUMP_DIR"
    if checkCouchbaseIsNotInitialized; then
        initializeCouchbase
        echo "cluster : $COUCHBASE_HOST initialized"
    fi
    dumpCouchbaseBucketAll
    echo "result      : terminated"
    exit 0;
}

function doCouchbaseCreate { 
    checkCouchbaseEnv
    echo "=             Create couchbase database"
    echo "==================================" 
    echo "host        : $COUCHBASE_HOST"
    if $(checkCouchbaseBucketsExist); then
        echo "! Bucket already exist"
        echo "You must run 'sx-dbtools couchbase delete' before this action"
        echo "You can also run 'sx-dbtools couchbase reset' to perform delete a create all in one"
        exit 1;
    else
        echo "source dir  : $COUCHBASE_DUMP_DIR"
        createCouchbaseBuckets $COUCHBASE_BUCKET
        loadCouchbaseBucketData $COUCHBASE_BUCKET
        echo "result      : terminated"
        exit 0;
    fi
}

function doCouchbaseDelete { 
    checkCouchbaseEnv
    echo "=             Delete couchbase database"
    echo "==================================" 
    echo "host        : $COUCHBASE_HOST"
    if checkCouchbaseIsNotInitialized; then
        initializeCouchbase
        echo "cluster : $COUCHBASE_HOST initialized"
    fi
    if $(checkCouchbaseBucketsExist); then
        deleteCouchbaseBucket $COUCHBASE_BUCKET
        echo "result      : terminated"
        exit 0;
    else
        echo "! Bucket doesn't exist"
        echo "nothing to delete. Action is terminated"
        exit 1;
    fi
}

function doCouchbaseReset { 
    checkCouchbaseEnv
    echo "=             Reset couchbase database"
    echo "==================================" 
    echo "host        : $COUCHBASE_HOST"
    if checkCouchbaseIsNotInitialized; then
        initializeCouchbase
        echo "cluster : $COUCHBASE_HOST initialized"
    fi
    if $(checkCouchbaseBucketsExist); then
        echo "source dir  : $COUCHBASE_DUMP_DIR"
        deleteCouchbaseBucket $COUCHBASE_BUCKET
        createCouchbaseBuckets $COUCHBASE_BUCKET
        loadCouchbaseBucketData $COUCHBASE_BUCKET
        echo "result      : terminated"
        exit 0;
    else
        echo "source dir  : $COUCHBASE_DUMP_DIR"
        createCouchbaseBuckets $COUCHBASE_BUCKET
        loadCouchbaseBucketData $COUCHBASE_BUCKET
        echo "result      : terminated"
        exit 0;
    fi
}
