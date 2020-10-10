#!/usr/bin/env bash

set -e

WORKDIR=/tmp/backup
LOGFILE=$WORKDIR/backup.log

mkdir -p $WORKDIR

echo dump all entities as json
while IFS='=' read -r name value ; do
  if [[ $name == 'BW_USER_'* ]]; then
    user_name=${!name}
    user_postfix=${name#"BW_USER_"}
    password_variable="BW_PASSWORD_$user_postfix"
    user_password=${!password_variable}
    if [ -z "$user_password" ]
    then
      echo "corresponding password variable for '$name' is not set"
      exit 1
    fi
    echo "exporting entries for user '$user_name'"
    mkdir -p $WORKDIR/$user_name/attachments
    ./exportBitwarden.sh $user_name $user_password $WORKDIR/$user_name/export-"$user_name".json $WORKDIR/$user_name/attachments
  fi
done < <(env)

echo dump database as sql
./dumpDb.sh $WORKDIR/database.sql

echo backup database
./backupDb.sh $WORKDIR/backup.sqlite3

echo copy attachments

if [[  -d /data/attachments ]]
then
    cp --recursive /data/attachments $WORKDIR
fi

echo creating archive

if [ -z "$BACKUP_PASSWORD" ]
    then
      echo "backup password is not set"
      exit 1
    fi

7z a -p$BACKUP_PASSWORD /out/backup_$(date +"%Y%m%d_%H%M%S").7z $WORKDIR  >> $LOGFILE

echo "Done!"
rm -rf $WORKDIR
