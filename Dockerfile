FROM alpine:3.9
LABEL maintainer "Bernard Ojengwa <bernardojengwa@gmail.com>"

RUN sed -i 's/http\:\/\/dl-cdn.alpinelinux.org/https\:\/\/alpine.global.ssl.fastly.net/g' /etc/apk/repositories

RUN apk update
RUN apk add --no-cache python py-pip py-setuptools ca-certificates libmagic curl
RUN pip install python-dateutil python-magic

RUN S3CMD_CURRENT_VERSION=`curl -fs https://api.github.com/repos/s3tools/s3cmd/releases/latest | grep tag_name | sed -E 's/.*"v?([0-9\.]+).*/\1/g'` \
  && mkdir -p /opt \
  && wget https://github.com/s3tools/s3cmd/releases/download/v${S3CMD_CURRENT_VERSION}/s3cmd-${S3CMD_CURRENT_VERSION}.zip \
  && unzip s3cmd-${S3CMD_CURRENT_VERSION}.zip -d /opt/ \
  && ln -s $(find /opt/ -name s3cmd) /usr/bin/s3cmd \
  && ls /usr/bin/s3cmd

RUN apk add postgresql

ENV PGHOST 'localhost:32768'
ENV PGDATABASE 'accounts'
ENV PGUSER 'postgres'
ENV PGPASSWORD ''
ENV NAMESPACE 'prod'
ENV S3_BUCKET_NAME ''
ENV S3_REGION 'us-west-2'
ENV S3_HOSTNAME 's3.amazonaws.com'
ENV S3_BACKUP_PATH 'backups'
ENV S3_ACCESS_KEY_ID '**None**'
ENV S3_SECRET_ACCESS_KEY '**None**'

COPY backup.sh .
COPY restore.sh .

RUN chmod a+x ./backup.sh
RUN chmod a+x ./restore.sh

ENTRYPOINT [ "/bin/sh" ]
CMD [ "./backup.sh" ]