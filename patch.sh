#!/bin/bash

git checkout release/v$1
CURRENT_VERSION=''
NEXT_VERSION=''
PATCH_NUMBER=0

function is_branch_synced() {
    git fetch origin master:master
    git fetch origin release/v$1:release/v$1

    if [ x"$(git rev-parse master)" = x"$(git rev-parse origin/master)" ]
    then
        echo master updated
    else
        echo please sync master first
        exit 1
    fi
    if [ x"$(git rev-parse release/v$1)" = x"$(git rev-parse origin/release/v$1)" ]
    then
        echo release/v$1 updated
    else
        echo please sync release/v$1 first
        exit 1
    fi
}

function read_write_version() {
    while IFS='' read -r LINE || [[ -n "$LINE" ]]; do
        if [[ $LINE =~ version.* ]]
        then
            CURRENT_VERSION=$(echo $LINE| cut -d'"' -f 4)
            PATCH_NUMBER=$(echo $CURRENT_VERSION| cut -d'.' -f 3)
            NEXT_VERSION="${CURRENT_VERSION/%$PATCH_NUMBER/$((PATCH_NUMBER+1))}"
            PATCH_NUMBER=$((PATCH_NUMBER+1))
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
    echo patch: $PATCH_NUMBER
    echo next version: $NEXT_VERSION
}

function commit_version_patch() {
    git add package.json
    git commit -m v$NEXT_VERSION
}

function pick_new_commits_from_release() {
    local mlatestversion=$(git log master -E --grep=v[0-9]+.[0-9]+.[0-9]+ --pretty=%s --max-count=1)
    local rhash=$(git log release/v$1 --all-match --grep=$mlatestversion --pretty=%h --max-count=1)
    local rhashs=$(git log release/v$1 $rhash..HEAD --pretty=format:%h --reverse)
    if [[ $rhash == '' ]]
    then
        echo master version $mlatestversion can not be found in release/v$1
        exit 1
    fi
    echo master latest:$mlatestversion
    echo release hash: $rhash
    echo release new hashs: $rhashs
    git checkout master
    echo git cherry-pick $rhashs --allow-empty
    git cherry-pick $rhashs --allow-empty
}

function sync_local_to_remote() {
    git checkout master
    git push
    git checkout release/v$1
    git push
}

function build_and_deploy() {
    git checkout release/v$1
    npm run build
    sh ./scripts/deploy.sh sit
    git checkout master
    npm run build
    sh ./scripts/deploy.sh dev
}

is_branch_synced $1
read_write_version
commit_version_patch
pick_new_commits_from_release $1
sync_local_to_remote $1
build_and_deploy $1
