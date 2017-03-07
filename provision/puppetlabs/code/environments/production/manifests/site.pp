 class { '::etckeeper':
    vcs => 'git',
 }


include sudo
include sso_ldap_client
include mail

node default {
}

node sierra.well.ox.ac.uk {

	postfix::config { 
		'header_checks': value => 'regexp:/etc/postfix/header_checks'
	}
	$header_checks = lookup({ 'name' => 'config::header_checks'})
	file {
		'/etc/postfix/header_checks':
		content => "${header_checks}"
	}

	include elk_server

	class { 'hiera':
		hierarchy => [
			'secure',
			'nodes/%{::trusted.certname}',
			'%{environment}',
			'common'
		],
		eyaml => true,
	}
}
