

include sudo
include sso_ldap_client

node default {
	include mail
}

node sierra.well.ox.ac.uk {
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
