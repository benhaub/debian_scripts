#! /bin/bash
###############################################################################
#Authour : Ben Haubrich                                                       #
#File    : change_session_manager.bash                                        #
#Synopsis: Change the default session-manager for the DisplayManager          #
#Date    : August 27th, 2020                                                  #
###############################################################################

if [ `whoami` != "root" ]; then
  echo "Please re-run as root (i.e sudo change_session_manager)"
  exit 1
elif [ $# -le 0 ]; then
  echo "Usage: change_session_manager <path-to-session-manager>"
  echo "Available Managers:"
  update-alternatives --list x-session-manager
  exit 1
fi

update-alternatives --set x-session-manager $1
