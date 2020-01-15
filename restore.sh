#!/usr/bin/env sh

echo "Current Version:" $S3CMD_CURRENT_VERSION
if [ ! -z $S3CMD_VERSION ]; then
    echo "Wanted version: " $S3CMD_VERSION
fi

if [ ! -z $S3CMD_CURRENT_VERSION ] && [ ! -z $S3CMD_VERSION ] && [ $S3CMD_CURRENT_VERSION != $S3CMD_VERSION ]; then
    echo "Version differ"
    set -x
    wget -T 10 https://github.com/s3tools/s3cmd/releases/download/v${S3CMD_VERSION}/s3cmd-${S3CMD_VERSION}.zip -P /opt/
    unzip -o /opt/s3cmd-${S3CMD_VERSION}.zip -d /opt
    ln -fs /opt/s3cmd-${S3CMD_VERSION}/s3cmd /usr/bin/s3cmd
    rm /opt/s3cmd-${S3CMD_VERSION}.zip
    set +x
fi

DUMP_FILE_NAME="^(?!.*$APP).*"
echo "Downloading the latest dump files: $DUMP_FILE_NAME"

S3_DIR="s3://$S3_BUCKET_NAME/$S3_BACKUP_PATH/$NAMESPACE/"
s3cmd get $S3_DIR --rexclude=$DUMP_FILE_NAME --recursive --access_key=$S3_ACCESS_KEY_ID --secret_key=$S3_SECRET_ACCESS_KEY --region=$S3_REGION --host=$S3_HOSTNAME

echo "Show current dir"
echo $(pwd)

echo "List all files"
echo $(ls)

# Restore the most recent backup
pg_restore -c -1 --no-acl -f "$(ls *.dump | tail -n1)"

if [ $? -ne 0 ]; then
  rm "*.dump"
  echo "Back up not restored, check db connection settings"
  exit 1
fi

rm "*.dump"
echo 'Successfully  restored'
exit 0
