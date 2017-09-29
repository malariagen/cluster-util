#!/bin/bash
if [ $UID -ne 0 ]
then
	echo "Must be run as root"
	exit 1
fi

if [ $(hostname) = 'localhost' ]
then
    echo "hostname must be set"
    exit 1
fi
PUPPET_SERVER=$1
TUNNEL=$2
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
wget https://apt.puppetlabs.com/puppetlabs-release-pc1-xenial.deb
dpkg -i puppetlabs-release-pc1-xenial.deb
gpg --keyserver pgp.mit.edu --recv-key 7F438280EF8D349F
apt-get update
apt-get install puppet-agent
export PATH=$PATH:/opt/puppetlabs/bin
grep puppetlabs ~/.bashrc || echo "export PATH=$PATH:/opt/puppetlabs/bin" >> ~/.bashrc
cat > /etc/puppetlabs/puppet/puppet.conf <<EOF
# This file can be used to override the default puppet settings.
# See the following links for more details on what settings are available:
# - https://docs.puppetlabs.com/puppet/latest/reference/config_important_settings.html
# - https://docs.puppetlabs.com/puppet/latest/reference/config_about_settings.html
# - https://docs.puppetlabs.com/puppet/latest/reference/config_file_main.html
# - https://docs.puppetlabs.com/puppet/latest/reference/configuration.html
[main]
server = ${PUPPET_SERVER}
certname = $(hostname -f)
environment = production
runinterval = 1h

EOF
if [ "${TUNNEL}" = "tunnel" ]
then
	#This is a duplicate of puppet configuration
	adduser fallback --home /fallback
	mkdir /fallback/.ssh
	chown fallback:fallback /fallback/.ssh
	chmod 700 /fallback/.ssh
	cat > /fallback/.ssh/authorized_keys <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDUZCJ6uRkoKKIkneZo/tZexlTZ8k7N4LUXCqdGAWjI6Zsva+zSj1TVGU0ra0B23OlanzujtgpzPEeSGDe/1NdDt7jS/nmgA1/tEeuA5SA0SJIlXLqxKjpgKABqWB52aklP/oyMJN87xMzuczweXgI66fBWLp4vrpRWJSenfX2WsuiADb3kGmimtSYWPemE9GmLwSxizNzkOAiH7NOMThcyBcviwKcBxg53mkT+mKbbSSkb9TERD3jG1Qh7/Qlu1pPn40c/jqFRebDC6/aFH/RIGWlCVyJvMsQej4+GCLPAz55+JC+YYzSL3OW6ePZ/7DNBCjGDQFoNhGQ+M0aHhfLd fallback@sierra
EOF
	chown fallback:fallback /fallback/.ssh/authorized_keys
	chmod 600 /fallback/.ssh/authorized_keys
	grep ${PUPPET_SERVER} /etc/hosts || sed -i "/localhost/ s/$/ ${PUPPET_SERVER}/" /etc/hosts
	echo "Create a tunnel from ${PUPPET_SERVER}"
fi
puppet agent --test --noop --server ${PUPPET_SERVER}
echo "Run puppet cert --sign $(hostname -f) on ${PUPPET_SERVER}"
