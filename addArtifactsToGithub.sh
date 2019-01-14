# add artifacts to the release
# note that we expect artifacts for each platform to be located in separate sub-dirs,
# and we add these zipped sub-dirs to the release

GH_OWNER=$1
GH_REPO=$2
GH_ACCESS_TOKEN=$3
TAG_NAME=$4
ARTIFACTS_DIR="build"
ARTIFACTS_NAME="build.zip"

zip -Z store -r "$ARTIFACTS_NAME" "$ARTIFACTS_DIR"
file_size=$(stat -f%z $ARTIFACTS_NAME)

release_id=$(
    curl -X GET \
        "https://github.build.ge.com/api/v3/repos/$GH_OWNER/$GH_REPO/releases?tag_name=$TAG_NAME" \
        --silent \
        -u "lanzhiping:$GH_ACCESS_TOKEN" \
        | grep -o -E -m 1 "\"id\": [0-9]+" \
        | awk '{print $2}' )

curl -X POST \
  "https://github.build.ge.com/storage/releases/$release_id/files" \
  --silent \
  -u "lanzhiping:$GH_ACCESS_TOKEN" \
  -F content_type=application/zip \
  -F name=$ARTIFACTS_NAME \
  -F file=@$ARTIFACTS_NAME \
  -F size=$file_size

if [ "$?" -eq "0" ]
then
  echo "Release successful!"
    exit 0
else
  echo "Error while running upload"
  exit 1
fi


