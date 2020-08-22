#! /bin/bash
###############################################################################
#Author  : Ben Haubrich                                                       #
#File    : backup.bash                                                        #
#Synopsis: Backup either a windows or linux disk to a remote server           #
#Date    : May 24th, 2020                                                     #
###############################################################################

#When a disk belonging to an OS has been selected, we check to see if we can
#find the disk in /dev and verify that it has a file system that matches the OS.
#The disk is mounted in a folder that can have a configured name by
#editing WMOUNT_NAME for windows backups and LMOUNT_NAME for linux backups.
#Then we try rsync on the remote server given. The data is copied to the
#directory of your choice. After the backup is complete (or fails).
#the files are unounted.

#All the disks on this system
DISKS=`ls /dev/sd[a-z]`
#Name of the windows directory in /media for the mount point.
WMOUNT_NAME=/media/windows
#Name of the linux directory in /media for the mount point.
LMOUNT_NAME=/media/`lsb_release -i | cut -d":" -f2 | tr -d "\t"`

if [ `whoami` != "root" ]; then
  echo "Please re-run with sudo"
  exit 1
fi

if [ $1 == "help" -o $1 == "Help" -o $1 == "h" ]; then
  echo -n "Back up either the disk the belongs to either a windows (w) or linux "
  echo "(l) operating system."
  echo "Options:"
  echo "w"
  echo -e "\t Backup a disk associated with a Windows operating system."
  echo "l"
  echo -e "\t Backup a disk associated with a Linux operating system."
  echo "user@hostname"
  echo -e "\t The remote host and user to copy the backup to"
  echo "dir"
  echo -e "\t The directory on the remote system to backup to"
  exit 0
fi

if [ $# -lt 3 ]; then
  echo "Usage: backup.bash [help] <w|l> <user@hostname> <dir>"
  exit 1
fi

if [ "$1" == "w" -o "$1" == "windows" -o "$1" == "Windows" ]; then
  BACKUP_DISK=`echo $DISKS | xargs sfdisk -l 2>/dev/null | egrep -i "HPFS|NTFS|exFAT" | cut -d" " -f1`
  if [ ! -d $WMOUNT_NAME ]; then
    echo -n "this script will now create the file $WMOUNT_NAME as a mount point. "
    echo "Do you wish to continue (y|n)?"
    read -n 1
    if [ "$REPLY" == "y" ]; then
      mkdir $WMOUNT_NAME
    else
      exit 0
    fi
  fi
  FS_TYPE=`lsblk -f $BACKUP_DISK | cut -d" " -f2 | tail -1`
  mount -t $FS_TYPE $BACKUP_DISK $WMOUNT_NAME
elif [ $1 == "l" -o $1 == "linux" -o $1 == "Linux" -o $1 == `uname -s` ]; then
  BACKUP_DISK=`echo $DISKS | xargs sfdisk -l 2>/dev/null | egrep -i "Linux filesystem" | cut -d" " -f1`
  if [ ! -d $LMOUNT_NAME ]; then
    echo -n "this script will now create the file $LMOUNT_NAME as a mount point. "
    echo "Do you wish to continue (y|n)?"
    read -n 1
    if [ "$REPLY" == "y" ]; then
      mkdir $LMOUNT_NAME
    else
      exit 0
    fi
  fi
  FS_TYPE=`lsblk -f $BACKUP_DISK | cut -d" " -f2 | tail -1`
  mount -t $FS_TYPE $BACKUP_DISK $LMOUNT_NAME
fi

echo "This script will now execute a backup of:"
sfdisk -l $BACKUP_DISK
echo "to $2:$3. Do you wish to continue (y|n)"
#Using RESP here just because I can. No reason not to use REPLY again.
read -n 1 RESP

#Backup the disk using rsync to the remote server.
#-A and --no-perms fix permission errors with mkstemp.
if [ "$RESP" == "y" ]; then
  if [ -d $LMOUNT_NAME ]; then
    rsync -Aav --no-perms --links $LMOUNT_NAME -e ssh $2:$3
  else
    rsync -Aav --no-perms --links $WMOUNT_NAME -e ssh $2:$3
  fi
  RSYNC_STAT=$?
  if [ $? -eq 1 ]; then
    echo "rsync failed to back up"
  fi
fi

#unmount the filesystem
if [ "$1" == "w" -o "$1" == "windows" -o "$1" == "Windows" ]; then
  umount -l $WMOUNT_NAME
  rmdir $WMOUNT_NAME
else
#The linux fs mounted and running on a linux os is likely to return an error
#that it's in use. Lazy unmount will unmount as soon as it's not in use.
  umount -l $LMOUNT_NAME
  rmdir $LMOUNT_NAME
fi

exit $RSYNC_STAT
