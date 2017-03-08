# Class: sso_ldap_client
# ===========================
#
# Full description of class sso_ldap_client here.
#
# Parameters
# ----------
#
# Document parameters here.
#
# * `sample parameter`
# Explanation of what this parameter affects and what it defaults to.
# e.g. "Specify one or more upstream ntp servers as an array."
#
# Variables
# ----------
#
# Here you should define a list of variables that this module would require.
#
# * `sample variable`
#  Explanation of how this variable affects the function of this class and if
#  it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#  External Node Classifier as a comma separated list of hostnames." (Note,
#  global variables should be avoided in favor of class parameters as
#  of Puppet 2.6.)
#
# Examples
# --------
#
# @example
#    class { 'sso_ldap_client':
#      servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#    }
#
# Authors
# -------
#
# Author Name <author@domain.com>
#
# Copyright
# ---------
#
# Copyright 2017 Your name here, unless otherwise noted.
#
class sso_ldap_client {

	$fallback_user = lookup({ 'name' => 'config::fallback_user'})
	$fallback_auth = lookup({ 'name' => 'config::fallback_auth'})

	@user { "${fallback_user}":
				ensure => present,
				comment => 'Fallback user',
				home => "/home/${fallback_user}",
				password => "${fallback_auth}",
				groups => ["sudo"],
				managehome => true
	}

	realize(User["${fallback_user}"])

	$fallback_ssh_key = lookup({ 'name' => 'config::fallback_ssh_key'})
	ssh_authorized_key { 'fallback_ssh':
		  user => "${fallback_user}",
		  type => 'rsa',
		  key => "${fallback_ssh_key}"
	}

	class {'::sssd':
	  config => {
	    'sssd' => {
	      'domains'             => 'malariagen',
	      'config_file_version' => 2,
	      'services'            => ['nss', 'pam', 'sudo'],
	#      'services'            => ['nss', 'pam', 'ssh'],
	    },
	    'domain/malariagen' => {
	      'cache_credentials'              => true,
	      'id_provider'                    => 'ldap',
	      'auth_provider'                    => 'ldap',
	      'ldap_schema'                     => 'rfc2307bis',
	      'default_shell'                  => '/bin/bash',
          #https://bugs.launchpad.net/ubuntu/+source/sssd/+bug/1249777
	      'sudo_provider'                  => 'none',
	      'ldap_uri'    => lookup({ 'name' => 'config::domain::malariagen::ldap_uri', 'default_value' => [ 'ldap://192.168.9.1/' ]}),
	      'ldap_default_bind_dn'    => lookup({ 'name' => 'config::domain::malariagen::ldap_default_bind_dn', 'default_value' => 'cn=admin,dc=malariagen,dc=net'}),
	      'ldap_default_authtok'    => lookup({ 'name' => 'config::domain::malariagen::ldap_default_authtok', 'default_value' => 'password'}),
	      'ldap_search_base'    => lookup({ 'name' => 'config::domain::malariagen::ldap_search_base', 'default_value' => 'dc=malariagen,dc=net'})
	#      'ldap_access_filter' = (&(objectClass=posixAccount)(gidNumber=9999))
	#      'ldap_user_ssh_public_key' = sshPublicKey
	    }
	  }
	} ->
	file { "/etc/ssh/ldap-keys.sh":
	    mode => "0700",
	    owner => root,
	    group => root,
	    content => epp('sso_ldap_client/ldap-keys_sh.epp', { 'login_filter' => lookup({ 'name' => 'config::domain::malariagen::ldap_login_filter', 'default_value' => ''})})
	}
}
