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
class profile::ldap::client(
    String $fallback_user = 'fallback',
    String $fallback_auth,
    String $fallback_ssh_key,
    $ldap_uri = [ 'ldap://192.168.9.1/' ],
    String $ldap_default_bind_dn = 'cn=admin,dc=malariagen,dc=net',
    String $ldap_default_authtok = 'password',
    String $ldap_search_base = 'dc=malariagen,dc=net',
    String $ldap_auth_filter = '',
    $hosts
) {


    $hosts.each |$host| {
        host { $host["name"]:
          ensure       => 'present',
          ip           => $host[ip],
          host_aliases           => $host[aliases],
    }

    }
	@user { "${fallback_user}":
				ensure => present,
				comment => 'Fallback user',
				home => "/${fallback_user}",
				password => "${fallback_auth}",
				groups => ["sudo"],
				managehome => true
	}

	realize(User["${fallback_user}"])

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
	      'ldap_uri'    => $ldap_uri,
	      'ldap_default_bind_dn' => $ldap_default_bind_dn,
	      'ldap_default_authtok'    => $ldap_default_authtok,
	      'ldap_search_base'    => $ldap_search_base,
	#      'ldap_access_filter' = (&(objectClass=posixAccount)(gidNumber=9999))
	#      'ldap_user_ssh_public_key' = sshPublicKey
	    }
	  }
	} ->
	file { "/etc/ssh/ldap-keys.sh":
	    mode => "0700",
	    owner => root,
	    group => root,
	    content => epp('profile/ldap/client/ldap-keys_sh.epp', { 'login_filter' => $ldap_auth_filter })
	}

}
