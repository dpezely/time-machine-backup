#! /bin/bash

# Usage:
# Assuming backup storage devices has been mounted as /mnt, run:
# mkdir /mnt/backups
# ~/bin/time-machine-backup.sh $HOME /mnt/

set -e

#OS=$(uname -s)
#HOST=$(hostname)
TIMESTAMP=$(date "+%Y-%m-%d-%H%M")
YEAR=$(date +%Y)
#MONTH=$(date +%m)
RSYNC_OPTIONS="--archive --partial"
EXCLUDES="$HOME/.rsync/exclusions"
BACKUPS="backups"

# Remember `rsync` applies semantics based upon paths ending with / or not
SOURCE="$(echo $1 | sed 's/\/$//')"
DEST="$(echo $2 | sed 's/\/$//')"

if [[ -z "$2" ]]; then
    echo "Usage: $0 <source> <destination>"
    echo "Use absolute paths."
    echo "Destination path will be appended with: $BACKUPS/<year>/<timestamp>/"
    exit 1
fi

if [[ ! -d "$DEST/$BACKUPS" ]]; then
    echo "Is the destination correct? $DEST/$BACKUPS/"
    echo "Please create $DEST/$BACKUPS first."
    exit 2
fi

[ -d "$DEST/$BACKUPS/$YEAR" ] || mkdir "$DEST/$BACKUPS/$YEAR"

mkdir "$DEST/$BACKUPS/$YEAR/$TIMESTAMP"

if [[ ! -L "$DEST/$BACKUPS/current" ]]; then
    echo "Bootstrapping... first backup"
    rsync $RSYNC_OPTIONS \
	--exclude-from="$EXCLUDES" \
	"$SOURCE" \
	"$DEST/$BACKUPS/$YEAR/$TIMESTAMP"
else
    rsync $RSYNC_OPTIONS \
	--exclude-from="$EXCLUDES" \
	--link-dest="$DEST/$BACKUPS/current" \
	"$SOURCE" \
	"$DEST/$BACKUPS/$YEAR/$TIMESTAMP"
fi

rm -f "$DEST/$BACKUPS/current"
ln -s $YEAR/$TIMESTAMP "$DEST/$BACKUPS/current"

echo "Done: $0"
