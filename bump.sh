#!/bin/bash

function is_master_synced() {
    git fetch origin master:master
    git pull --reb origin master

    if [ x"$(git rev-parse master)" = x"$(git rev-parse origin/master)" ]
    then
        echo master updated
    else
        echo please sync master first
        exit 1
    fi
}

function read_write_version() {
    while IFS='' read -r LINE || [[ -n "$LINE" ]]; do
        if [[ $LINE =~ version.* ]]
        then
            CURRENT_VERSION=$(echo $LINE| cut -d'"' -f 4)
            local patchNum=$(echo $CURRENT_VERSION| cut -d'.' -f 3)
            local featureNum=$(echo $CURRENT_VERSION| cut -d'.' -f 2)

            NEXT_VERSION=${CURRENT_VERSION/\.$featureNum\.$patchNum/\.$((featureNum+1))\.0}

            echo "${LINE/$CURRENT_VERSION/$NEXT_VERSION}"
        else
            echo "$LINE"
        fi
    done < package.json > package.json.temp
    mv package.json{.temp,}

    if [[ $CURRENT_VERSION == '' ]]
    then
        echo no version found in package.json
        exit 1
    fi

    echo current version: $CURRENT_VERSION
    echo next version: $NEXT_VERSION
}

function bump_version() {
    git add package.json
    git commit -m "v${NEXT_VERSION}"
    git push

    local mainNum=$(echo $NEXT_VERSION| cut -d'.' -f 1)
    local featureNum=$(echo $NEXT_VERSION| cut -d'.' -f 2)

    git checkout -b release/v$mainNum.$featureNum
    git push -u origin release/v$mainNum.$featureNum
}

# main process
git checkout master
is_master_synced

CURRENT_VERSION=''
NEXT_VERSION=''
read_write_version

bump_version
