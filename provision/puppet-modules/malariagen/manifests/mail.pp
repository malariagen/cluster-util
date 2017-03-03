$trusted_hostname = $trusted[hostname]


user { 'root':
	comment => "$trusted_hostname root"
}

include postfix

postfix::config { 
	'relay_domains': ensure  => present, value   => 'localhost malariagen.net',
}
postfix::config { 
	'relayhost': ensure  => present, value   => 'smtp.gmail.com:587';
	'smtp_tls_security_level': ensure => present, value => 'may';
	'smtp_sasl_password_maps': ensure => present, value => 'hash:/etc/postfix/sasl_passwd';
}
postfix::hash { '/etc/postfix/sasl_passwd':
  ensure  => 'present',
  source  => 'puppet:///modules/profile/postfix/client/sasl_passwd',
}
postfix::config { 
	'header_checks': value => 'regexp:/etc/postfix/header_checks'
}
file {
	'/etc/postfix/header_checks':
	content => "/^To:.*@malariagen.net/  DUNNO
/^To:.*@/   DISCARD No outgoing mails allowed
"
}
