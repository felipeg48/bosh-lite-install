#!/bin/bash
. logMessages.sh

echo "###### Install RVM and download the appropriate version of Ruby ######"
RUBY_VERSION_INSTALLED=`ruby -v`

WHICH_RVM=`which rvm`
if [ -z $WHICH_RVM ]; then
	logCustom 9 "RVM not found. I knew you would never read the instructions. I have to install this for you now! Phew!!"
	\curl -sSL $RVM_DOWNLOAD_URL | bash >> $LOG_FILE 2>&1
	
	echo "Setting RVM for use in this bash session"
	`[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"`
	
	logInfo "Installed RVM, please fire the script again from a new terminal"
	exit 1
fi

if echo "$RUBY_VERSION_INSTALLED" | grep -q "$EXPECTED_RUBY_VERSION"; then
	logInfo "Ruby RubyGems Already Installed"
else
	logCustom 9 "Ruby not found. I knew you would never read the instructions. I have to install this for you now! Phew!!"		
	rvm install $REQUIRED_RUBY_VERSION >> $LOG_FILE 2>&1
	
	if [ $? -gt 0 ]; then
		logError "Unable to Install ruby"
	fi
	
	set +e
	echo "###### Using Ruby $REQUIRED_RUBY_VERSION ######"
	rvm use $REQUIRED_RUBY_VERSION --default >> $LOG_FILE 2>&1
	logInfo "Defaulted ruby to $REQUIRED_RUBY_VERSION. Close this terminal and open a new one. Fire the setup again."
	exit 1
fi