Time-Machine style backups for Linux & BSD
==========================================

## Overview

While another operating system has popularised the idea of backups with
snapshots, the concept has been around for a very long time in Unix with the
`dump` command.  The problem with that older approach is the pseudo-shell
used for recovering files and navigating multiple archives seem too limited
for contemporary user experience.

Since the earliest days of `rsync` that afforded hard-links, various
approaches have been built using that tool becacuse the resulting directory
tree is immediately available to confirm and inspect your files.  This makes
for much improved user experience when accessing archived files.

The current implementation of this script is the most minimal yet due to
mature features of `rsync` such that it does all the hard work.

Essentially once a baseline copy has been created, subsequent backups need
only take the time and storage space for just those files that have changed
plus some overhead for directory structure and cost of creating hard-links.

Your backup storage device requires a file system capable of handling
hard-links; see Unix Manual page for `ln` to get details on links.

Common file systems supporting links are zfs, ext4, ext2, ufs2, etc.

(Yes, there are many similar scripts available but can be needlessly
complicated.)

## Usage

**First Time Run**

Only need to do this once per backup storage device:

	sudo mount /dev/sdb1 /mnt
	mkdir /mnt/backups

Now that your backup storage device has been mounted as `/mnt`, omit the
first command of the next section only this once.

**Make Backup**

	sudo mount /dev/sdb1 /mnt

	~/bin/time-machine-backup.sh $HOME /mnt/

	sync
	sudo umount /mnt

**Restore**

Restoring files is simply a matter copying from the backup storage device
based upon past date or `current` for most recent version.

Of course, you'll need to mount the device first:

	sudo mount /dev/sdb1 /mnt

To restore your `~/.emacs` file from most recent backup, run:

	rsync -abv /mnt/backups/current/.emacs ~

Restoring one from end of January 2015 assuming a copy was made then, run:

	rsync -abv /mnt/backups/2015-01-31-1359/.emacs ~

When done, be sure to unmount:

	sudo umount /mnt

## Exclusions

Create `~/.rsync/exclusions` file with one line per entry, and add entries
for each file pattern to *not* be included within the remote copy.

Example:

	.*~
	*~
	._*
	*.a
	.adobe
	*.beam
	.cache
	Crash Reports
	.dmrc
	.emacs.d
	*.fasl*
	.ICEauthority
	.macromedia
	Music
	*.o
	Public
	scratch
	.sudo_as_admin_successful
	.thumbnails
	tmp
	VirtualBox VMs
	*.vbox
	*.vmdk
	.Xauthority
	.xsession-errors
	.xsession-errors.old

