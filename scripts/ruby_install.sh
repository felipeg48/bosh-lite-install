#!/bin/bash --login
. logMessages.sh

echo "###### Install RVM and download the appropriate version of Ruby ######"
RUBY_VERSION_INSTALLED=`ruby -v`

PASSWORD=$1
if echo "$RUBY_VERSION_INSTALLED" | grep -q "$EXPECTED_RUBY_VERSION"; then
	logInfo "Ruby RubyGems Already Installed"
else	
	\curl -sSL $RVM_DOWNLOAD_URL | bash >> $LOG_FILE 2>&1
	if [ $? -gt 0 ]; then
		echo $PASSWORD | \curl -sSL $RVM_DOWNLOAD_URL | sudo bash >> $LOG_FILE 2>&1
	fi
	`source ~/.rvm/scripts/rvm`
	`type rvm | head -n 1`
	
	WHICH_RVM=`which rvm`
	
	rvm install $REQUIRED_RUBY_VERSION >> $LOG_FILE 2>&1
	if [ $? -gt 0 ]; then
		echo $PASSWORD | sudo -S rvm install $REQUIRED_RUBY_VERSION >> $LOG_FILE 2>&1
	fi
	
	if [ $? -gt 0 ]; then
		logError "Unable to Install ruby"
	fi	
fi

echo "###### Using Ruby $REQUIRED_RUBY_VERSION ######"
rvm use $REQUIRED_RUBY_VERSION --default >> $LOG_FILE 2>&1