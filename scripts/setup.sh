#!/bin/bash

echo ">>>>>>>>>> Start time: $(date) <<<<<<<<<<<<"

export SUDO_PASSWORD=$1
export CF_RELEASE=cf-$2.yml
echo "Deploy CF release" $CF_RELEASE

export BOSH_RELEASES_DIR=$PWD
export LOG_FILE=$BOSH_RELEASES_DIR/setup.log

export BOSH_USER=admin
export BOSH_PASSWORD=admin

echo "######  Install Open Source CloudFoundry ######"
if [ $# -ne 3 ]; then
	echo "Usage: ./setup.sh <Password> <cf-release-version> <provider>"
	printf "\t %s \t\t %s \n" "Password:" "sudo password"
	printf "\t %s \t %s \n" "cf-release-version:" "Cloud foundry version to deploy on vagrant"
	printf "\t %s \t\t %s \n\t\t\t\t %s \n" "provider:" "Enter 1 for Virtual Box" "Enter 2 for VMWare Fusion"
	exit 1
fi

if [ -z $1 ]; then
	echo "Please provide the sudo password"
	exit 1
fi

if [ -z $2 ]; then
	echo "Please provide the cf release version to deploy"
	exit 1
fi

if [ $3 -eq 1 ] || [ $3 -eq 2 ]; then
	if [ $3 -eq 1 ]; then 
		echo "Provider selected : Virtual Box" 
	else 
		echo "Provider selected : VMWare Fusion."
		if [ ! -f $BOSH_RELEASES_DIR/license.lic ]; then
			tput setab 1
			echo "ERROR: Please place the license.lic file in $BOSH_RELEASES_DIR" 
			tput setab 2
			echo "INFO: Ensure you have the license.lic available. https://www.vagrantup.com/vmware"			
			tput sgr 0
			exit 1
		fi
	fi
else
	echo "Please provide the valid selection for the provider"
fi

echo "###### CLONE Required Git Repositories ######"
git clone https://github.com/cloudfoundry/bosh-lite.git bosh-lite > $LOG_FILE 2>&1
git clone https://github.com/cloudfoundry/cf-release.git cf-release > $LOG_FILE 2>&1
git clone https://github.com/cloudfoundry/cf-acceptance-tests.git cf-acceptance-tests > $LOG_FILE 2>&1
echo "###### CLONED Required Git Repositories ######"

echo "###### Install RVM and download the appropriate version of Ruby ######"
\curl -sSL https://get.rvm.io | bash > $LOG_FILE 2>&1
rvm install 1.9.3-p484 > $LOG_FILE 2>&1

cd bosh-lite

echo "###### Pull latest changes (if any) for bosh-lite ######"
git pull > $LOG_FILE 2>&1

echo "###### Installing Bundler ######"
gem install bundler > $LOG_FILE 2>&1

echo "###### Bundle bosh-lite ######"
bundle > $LOG_FILE 2>&1

echo "###### Vagrant up ######"
if [ $3 -eq 1 ]; then
	vagrant up > $LOG_FILE 2>&1
else
	vagrant plugin install vagrant-vmware-fusion > $LOG_FILE 2>&1
	vagrant plugin license vagrant-vmware-fusion $BOSH_RELEASES_DIR/license.lic > $LOG_FILE 2>&1
	vagrant up --provider vmware_fusion > $LOG_FILE 2>&1
fi

echo "###### Setup bosh target and login ######"
bosh target 192.168.50.4
bosh login $BOSH_USER $BOSH_PASSWORD

echo "###### Set the routing tables ######"
echo $1 | sudo -S scripts/add-route > $LOG_FILE 2>&1

brew install wget > $LOG_FILE 2>&1

echo "###### Download warden ######"
if [ ! -f latest-bosh-stemcell-warden.tgz ]; then
    echo "###### Downloading... warden ######"
    wget http://bosh-jenkins-gems-warden.s3.amazonaws.com/stemcells/latest-bosh-stemcell-warden.tgz -q $LOG_FILE 2>&1
else 
	echo "###### Skipping warden download, local copy exists ######";
fi

echo "###### Upload stemcell ######"
bosh upload stemcell latest-bosh-stemcell-warden.tgz > $LOG_FILE 2>&1

echo "###### Update cf-release repo ######"
cd $BOSH_RELEASES_DIR/cf-release
./update > $LOG_FILE

echo "###### Install spiff ######"
brew tap xoebus/homebrew-cloudfoundry
brew install spiff > $LOG_FILE 2>&1

#rvm gemset use bosh-lite
echo "###### Bundle cf-release ######"
bundle > $LOG_FILE 2>&1

echo "###### Upload cf-release" $CF_RELEASE "######"
bosh upload release releases/$CF_RELEASE > $LOG_FILE 2>&1

echo "###### Generate a manifest at manifests/cf-manifest.yml ######"
cd $BOSH_RELEASES_DIR/bosh-lite
./scripts/make_manifest_spiff > $LOG_FILE 2>&1

echo "###### Deploy the manifest manifests/cf-manifest.yml ######"
bosh deployment manifests/cf-manifest.yml > $LOG_FILE 2>&1
echo "yes" |bosh deploy > $LOG_FILE 2>&1

echo ">>>>>>>>>> End time: $(date) <<<<<<<<<<<<"
echo "###### Congratulations: Open Source CloudFoundry setup complete! ######"



