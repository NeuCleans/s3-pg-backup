#!/usr/bin/env bash

echo "Current Version:" $S3CMD_CURRENT_VERSION
if [ ! -z $S3CMD_VERSION ]; then
    echo "Wanted version: " $S3CMD_VERSION
fi

echo "Current Path 1"
echo $(pwd)

if [ ! -z $S3CMD_CURRENT_VERSION ] && [ ! -z $S3CMD_VERSION ] && [ $S3CMD_CURRENT_VERSION != $S3CMD_VERSION ]; then
    echo "Version differ"
    set -x
    wget -T 10 https://github.com/s3tools/s3cmd/releases/download/v${S3CMD_VERSION}/s3cmd-${S3CMD_VERSION}.zip -P /opt/
    unzip -o /opt/s3cmd-${S3CMD_VERSION}.zip -d /opt
    ln -fs /opt/s3cmd-${S3CMD_VERSION}/s3cmd /usr/bin/s3cmd
    rm /opt/s3cmd-${S3CMD_VERSION}.zip
    set +x
fi

DUMP_FILE_NAME="$APP-db-`date +%Y-%m-%d-%H-%M`.dump"
echo "Creating dump: $DUMP_FILE_NAME"

TEMP_FILE=$(mktemp tmp.XXXXXXXXXX)
S3_FILE="s3://$S3_BUCKET_NAME/$S3_BACKUP_PATH/$NAMESPACE/$DUMP_FILE_NAME"
pg_dump -C -w --format=c --no-acl --blobs > $TEMP_FILE

if [ $? -ne 0 ]; then
  rm $TEMP_FILE
  echo "Back up not created, check db connection settings"
  exit 1
fi
s3cmd put $TEMP_FILE $S3_FILE --access_key=$S3_ACCESS_KEY_ID --secret_key=$S3_SECRET_ACCESS_KEY --region=$S3_REGION --host=$S3_HOSTNAME
rm "$TEMP_FILE"
echo 'Successfully Backed Up'

echo "Current Path 2"
echo $(pwd)

exit 0