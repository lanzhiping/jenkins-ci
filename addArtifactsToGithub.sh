# environment variables are required: GH_ACCESS_TOKEN

GH_ACCESS_TOKEN=$1
GH_OWNER="hc-apm"
GH_REPO="hc-apm-ce"
ARTIFACTS_DIR="dist"
ARTIFACTS_NAME="dist.zip"

zip -Z store -r "$ARTIFACTS_NAME" "$ARTIFACTS_DIR"
file_size=$(stat -c%s $ARTIFACTS_NAME)
current_version=''

function read_version() {
    while IFS='' read -r LINE || [[ -n "$LINE" ]]; do
        if [[ $LINE =~ version.* ]]
        then
            current_version=$(echo $LINE| cut -d'"' -f 4)
        fi
    done < package.json

    if [[ $current_version == '' ]]
    then
        echo no version found in package.json
        exit 1
    fi
    echo current version: $current_version
}
read_version
tag_name=v$current_version

# create release
release_id=$(curl -X POST \
    "https://github.build.ge.com/api/v3/repos/$GH_OWNER/$GH_REPO/releases" \
    -s \
    -u "lanzhiping:$GH_ACCESS_TOKEN" \
    -H 'content-type: application/json' \
    -d '{
    "tag_name": "'$tag_name'",
    "name": "'$tag_name'",
    "body": "'"Release $tag_name"'",
    "draft": false,
    "prerelease": false
    }' \
    | grep -o -E -m 1 "\"id\": [0-9]+" \
    | awk '{print $2}' )

echo "release id: $release_id"

result=$(curl -X POST \
    "https://github.build.ge.com/storage/releases/$release_id/files" \
    -s \
    -u "lanzhiping:$GH_ACCESS_TOKEN" \
    -F "content_type=application/zip" \
    -F "name=$ARTIFACTS_NAME" \
    -F "file=@$ARTIFACTS_NAME" \
    -F "size=$file_size" )

if [[ $result == *"Failed"* ]]; then
    echo "Error while running upload $result"
    exit 1
else
    echo "Release successful! $result"
    exit 0
fi
