#!/bin/bash
if [ "$1" == "dev" ]; then
  SERVER="dev.com"
fi

if [ "$1" == "uat" ]; then
  SERVER="uat.com"
fi

if [ "$1" == "sit" ]; then
  SERVER="sit.com"
fi

echo push to $SERVER...
echo deploying geops to $1

rsync -Pav -e "ssh -i ~/.ssh/id_rsa" build/directory/* $SERVER:/path/to/project

if [ "$?" -eq "0" ]
then
  echo "Done"
else
  echo "Error while running rsync"
  exit 1
fi
