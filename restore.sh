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

EXCLUDE_PATTERN="^(?!.*$APP).*"
echo "Downloading the latest dump files: $EXCLUDE_PATTERN"

S3_DIR="s3://$S3_BUCKET_NAME/$S3_BACKUP_PATH/$NAMESPACE/"
s3cmd get $S3_DIR --rexclude=$EXCLUDE_PATTERN --recursive --access_key=$S3_ACCESS_KEY_ID --secret_key=$S3_SECRET_ACCESS_KEY --region=$S3_REGION --host=$S3_HOSTNAME

echo "Show current dir"
echo $(pwd)


DUMP_FILE_NAME="$(pwd)/$(ls *.dump | tail -n1)"
echo "Restoring $DUMP_FILE_NAME"

# Restore the most recent backup
pg_restore -c --format=c  --if-exists --no-acl -f "$DUMP_FILE_NAME"

if [ $? -ne 0 ]; then
  rm "$(pwd)/*.dump"
  echo "Back up not restored, check db connection settings"
  exit 1
fi

rm "$(pwd)/*.dump"
echo 'Successfully  restored'
exit 0
