#!/bin/sh

set -e

if [ $# -ne 1 ]
then
    echo "usage: 0$ filename"
    exit -1
fi

sqlite3 /data/db.sqlite3 ".backup $1"
