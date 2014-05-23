#!/bin/bash
. logMessages.sh

BREW_INSTALLED=`which brew`
if [ -z $BREW_INSTALLED ]; then
	logCustom 15 "You don't have homebrew Installed. I knew you never read instructions. I have to install this for you now! Phew!!"
	if [ "$1" == "Darwin" ]; then
		logInfo "Installing HomeBrew on Mac"
		echo $2 | ruby -e "$(curl -C - -O $HOMEBREW_DOWNLOAD_URL)" >> $LOG_FILE 2>&1
		brew doctor >> $LOG_FILE 2>&1
		brew update >> $LOG_FILE 2>&1
	elif [ "$1" == "Ubuntu" ]; then
		logInfo "Install Linuxbrew on Ubuntu"
		echo $2 | sudo apt-get install build-essential / 
			curl git ruby texinfo libbz2-dev libcurl4-openssl-dev / 
			libexpat-dev libncurses-dev zlib1g-dev >> $LOG_FILE 2>&1
		git clone $LINUXBREW_GIT_REPO ~/.linuxbrew >> $LOG_FILE 2>&1
		export PATH="$HOME/.linuxbrew/bin:$PATH"
		export LD_LIBRARY_PATH="$HOME/.linuxbrew/lib:$LD_LIBRARY_PATH"
	fi
fi

GIT_INSTALLED=`which git`
if [ -z $GIT_INSTALLED ]; then
	brew install git git-flow
fi