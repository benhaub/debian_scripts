#! /bin/bash
###############################################################################
#Authour : Ben Haubrich                                                       #
#File    : netswtch.bash                                                      #
#Synopsis: Turn off/on the wired connection interface. This will usually cause#
#the device to switch to a wireless connection if it's avaialble.             #
#Date    : May 24th, 2020                                                     #
###############################################################################
STATE=
#Check to see if it's already down. If it is, bring it up
if [ "`nmcli -f GENERAL.STATE con show "Wired connection 1"`" == "" ]; then
  nmcli con up id "Wired connection 1"
else
  nmcli con down id "Wired connection 1"
fi
