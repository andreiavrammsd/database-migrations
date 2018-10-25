#!/usr/bin/env bash

# Get latest migrations files
cd ${REPOSITORY_DIR} && git pull --rebase && cd -

# Do not continue if no migrations exist yet
SOURCE=${REPOSITORY_DIR}/${MIGRATIONS_DIR}
migs=`find ${SOURCE} -name "*.sql"`
if [ -z "${migs}" ]; then
    echo No migrations yet
    exit 0
fi

# Get secret string from AWS secrets manager (database connection info)
secret=`aws secretsmanager get-secret-value --secret-id ${AWS_SECRET_ID} --version-stage AWSCURRENT`

# Extract database connection parameters from json secret string
urlencode() {
    RESULT=`python -c "import urllib;print urllib.quote(raw_input())" <<< "$1"`
}

db=`echo ${secret} | jq -r '.SecretString'`
hostname=`echo ${db} | jq -r '.hostname'`
port=`echo ${db} | jq -r '.port'`
database=`echo ${db} | jq -r '.database'`

username=`echo ${db} | jq -r '.username'`
urlencode "${username}"
username=${RESULT}

password=`echo ${db} | jq -r '.password'`
urlencode "${password}"
password=${RESULT}

# Perform migration
# Adapt to used engine: https://github.com/golang-migrate/migrate#databases
DIR=$1
STEPS=$2
migrate \
    -source=file://${SOURCE} \
    -database=mysql://${username}:${password}@\(${hostname}:${port}\)/${database} \
    ${DIR} ${STEPS}
