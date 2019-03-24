#!/bin/bash

#
#   Install OpenCV on ubuntu, rasbian or mac using this script.
#
shopt -s nocasematch
[[ "foo" == "Foo" ]] && echo "match" || echo "notmatch"

OSInfo=$(uname -a)
echo "$OSInfo"
if [[ "$OSInfo" == *"raspberrypi"* ]] ; then
	time ./install_on_raspberry.sh
elif [[ "$OSInfo" == *"ubuntu"* ]] ; then
    time ./install_on_ubuntu.sh
elif [[ "$OSInfo" == *"Darwin"* ]] ; then
    times ./install_on_mac.sh
elif [[ "$OSInfo" == *"CYGWIN"* || "$OSInfo" == *"MINGW"* ]] ; then
    printf "\e[31;40;1mWindows is currently unsupported!\e[0m\n"
else
    printf "\e[31;40;1mYour operating system is unknown!\e[0m\n"
fi
shopt -u nocasematch