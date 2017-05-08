#!/bin/bash

##
#SBUpdate.sh is a simple script designed to make mod development and testing a bit easier.
#
#The script uses SteamCMD and should be placed in the "steamcmd" folder. It will almost certainly not work if you place it elsewhere without some prep!
##

#You need to change this! Make sure to end with a slash, don't use a "~", and escape as needed!
INSTALLDIR="/media/Internal-1TB_data/LinDATA/Steam/steamapps/common/"

echo "SBUpdate.sh - I update stuff!"
echo ""
echo "Enter the first letter of a branch to update: ([N]ightly/[U]nstable/[S]table)"
read branch
echo ""
echo "Enter your steam username:"
read user
echo ""
echo "Enter your steam password:"
read -s pass

if [ "$branch" == "N" ] || [ "$branch" == "n" ] ; then
  echo "Are you sure you want to update the nightly branch? (Y/n)"
  read confirm
  if [ "$confirm" == "n" ] || [ "$confirm" == "N" ] ; then
    echo "Update canceled."
  else
    echo "Updating...."
    [ -d ${INSTALLDIR}Starbound.nightly ] || mkdir "${INSTALLDIR}Starbound.nightly"
    ./steamcmd.sh +login $user $pass +force_install_dir ${INSTALLDIR}Starbound.nightly "+app_update 367540 -beta nightly validate" +quit && echo "success!" || echo "Something went wrong."
    echo $(date) > ${INSTALLDIR}Starbound.nightly/timestamp.txt
  fi
elif [ "$branch" == "U" ] || [ "$branch" == "u" ] ; then
  echo "Are you sure you want to update the unstable branch? (Y/n)"
  read confirm
  if [ "$confirm" == "n" ] || [ "$confirm" == "N" ] ; then
    echo "Update canceled."
  else
    echo "Updating...."
    [ -d ${INSTALLDIR}Starbound.unstable ] || mkdir "${INSTALLDIR}Starbound.unstable"
    ./steamcmd.sh +login $user $pass +force_install_dir ${INSTALLDIR}Starbound.unstable "+app_update 367540 validate" +quit && echo "success!" || echo "Something went wrong."
    echo $(date) > ${INSTALLDIR}Starbound.unstable/timestamp.txt
  fi
elif [ "$branch" == "S" ] || [ "$branch" == "s" ] ; then
  echo "Are you sure you want to update the stable branch? (Y/n)"
  read confirm
  if [ "$confirm" == "n" ] || [ "$confirm" == "N" ] ; then
    echo "Update canceled."
  else
    echo "Updating...."
    [ -d ${INSTALLDIR}Starbound.stable ] || mkdir "${INSTALLDIR}Starbound.stable"
    ./steamcmd.sh +login $user $pass +force_install_dir ${INSTALLDIR}Starbound.stable "+app_update 211820 validate" +quit && echo "success!" || echo "Something went wrong."
    echo $(date) > ${INSTALLDIR}Starbound.stable/timestamp.txt
  fi
else
  echo "I couldn't understand what branch you selected. Please re-run the script and try again."
fi
