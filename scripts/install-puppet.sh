#!/bin/bash
if [ $UID -ne 0 ]
then
	echo "Must be run as root"
	exit 1
fi
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
wget https://apt.puppetlabs.com/puppetlabs-release-pc1-xenial.deb
dpkg -i puppetlabs-release-pc1-xenial.deb
gpg --keyserver pgp.mit.edu --recv-key 7F438280EF8D349F
apt-get update
apt-get install puppet-agent
export PATH=$PATH:/opt/puppetlabs/bin
#DO NOT RUN THIS
#puppet resource package puppet ensure=latest
cd ${DIR}/../provision/puppet/
cat code/environments/production/hieradata/common.yaml >> /etc/puppetlabs/code/environments/production/hieradata/common.yaml
./install-modules.sh 
cp -pr modules/* /etc/puppetlabs/code/modules/
vi /etc/puppetlabs/code/environments/production/hieradata/common.yaml
puppet apply -e "notice(lookup('sssd::config::domain::malariagen::ldap_uri'))" 
puppet apply  --verbose --detailed-exitcodes sso-ldap-client.pp 
