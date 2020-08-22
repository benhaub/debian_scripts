#! /bin/bash
###############################################################################
#Authour : Ben Haubrich                                                       #
#File    : getfstype.bash                                                     #
#Synopsis: Get the file system types of your disks that can be used with      #
#          mount(8)                                                           #
#Date    : May 24th, 2020                                                     #
###############################################################################

if [ $# -le 0 ]; then
  echo "Usage: getfstype <device>"
  exit 1
fi

file -sL $1
