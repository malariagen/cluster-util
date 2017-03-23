# Class: mail
# ===========================
#
# Full description of class mail here.
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
#    class { 'mail':
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
class profile::mail::relay(
    String $relay_domains,
    String $relay_host,
    String $relay_passwd,
    String $smtp_security_level = 'may',
    String $smtp_sasl_auth_enable = 'no',
    String $smtp_generic_maps,
    Optional[String] $header_checks = undef
) {

	$trusted_hostname = $trusted[hostname]


	user { 'root':
		comment => "$trusted_hostname root"
	}

	include postfix

	postfix::config { 
		'relay_domains': ensure  => present, value   => "${relay_domains}",
	}
	postfix::config { 
		'relayhost': ensure  => present, value   => "${relay_host}";
		'smtp_tls_security_level': ensure => present, value => "${smtp_security_level}";
		'smtp_sasl_password_maps': ensure => present, value => 'hash:/etc/postfix/sasl_passwd';
        'smtp_sasl_auth_enable': value => "${smtp_sasl_auth_enable}";
        'smtp_sasl_security_options': value => 'noanonymous';
        'smtp_sasl_tls_security_options': value => 'noanonymous';
        'compatibility_level': value => '2';

	}
	postfix::hash { '/etc/postfix/sasl_passwd':
	  ensure  => 'present',
	  content  => "${relay_passwd}"
	}

	postfix::config {
			'smtp_generic_maps': ensure => present, value => 'hash:/etc/postfix/smtp_generic_maps';
	}
	postfix::hash { '/etc/postfix/smtp_generic_maps':
	  ensure  => 'present',
	  content  => "${smtp_generic_maps}"
	}

    if $header_checks {
        postfix::config {
                'header_checks': value => 'regexp:/etc/postfix/header_checks'
        }
        file {
                '/etc/postfix/header_checks':
                content => "${header_checks}",
                require => [ Class["postfix"] ],
        }
    }
        
}
