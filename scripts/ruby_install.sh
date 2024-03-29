#!/bin/bash --login
. logMessages.sh

installRequiredGems () {
	set -e
	INSTALLED_BUNDLE_VERSION=`which bundle` >> $LOG_FILE 2>&1
	if [ -z $INSTALLED_BUNDLE_VERSION ]; then
		rvm use $1
		echo "###### Installing Bundler ######"
		gem install bundler >> $LOG_FILE 2>&1
	fi
	
	INSTALLED_BOSH_CLI=`which bosh`
	if [ -z $INSTALLED_BOSH_CLI ]; then
		echo "###### Installing BOSH CLI ######"
		gem install bosh_cli >> $LOG_FILE 2>&1
	fi
	
	if [ $? -gt 0 ]; then
		logError "Unable to install required Gems"
	else
		logInfo "Installed all required Gems"
	fi
}

installRuby () {
	RUBY_VERSION_INSTALLED=`rvm list | grep $1`
	
	logInfo "Validate if $RUBY_VERSION_INSTALLED is installed"
	
	if [ -z "$RUBY_VERSION_INSTALLED" ]; then
		logCustom 9 "Ruby not found. I knew you would never read the instructions. I have to install this for you now! Phew!!"		
		rvm install $1 >> $LOG_FILE 2>&1
		
		if [ $? -gt 0 ]; then
			logError "Unable to Install ruby"
		fi
	else
		logInfo "Ruby RubyGems Already Installed"	
	fi
	
	installRequiredGems $1
}


echo "###### Install RVM and download the appropriate version of Ruby ######"

WHICH_RVM=`which rvm`
if [ -z "$WHICH_RVM" ]; then
	logCustom 9 "RVM not found. I knew you would never read the instructions. I have to install this for you now! Phew!!"
	\curl -sSL $RVM_DOWNLOAD_URL | bash >> $LOG_FILE 2>&1
	
	echo "Setting RVM for use in this bash session"
	`[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"`
	
	logInfo "Installed RVM, please fire the script again from a new terminal"
	exit 1
fi

installRuby $EXPECTED_RUBY_VERSION_BOSH
installRuby $EXPECTED_RUBY_VERSION_CF_RELEASE

set +e
echo "###### Using Ruby $EXPECTED_RUBY_VERSION_BOSH ######"
rvm --default use $EXPECTED_RUBY_VERSION_BOSH >> $LOG_FILE 2>&1
logSuccess "Successfully set ruby to $EXPECTED_RUBY_VERSION_BOSH." 
