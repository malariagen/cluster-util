class {'::sssd':
  config => {
    'sssd' => {
      'domains'             => 'malariagen',
      'config_file_version' => 2,
      'services'            => ['nss', 'pam'],
    },
    'domain/malariagen' => {
      'cache_credentials'              => true,
      'id_provider'                    => 'ldap',
      'auth_provider'                    => 'ldap',
      'ldap_schema'                     => 'rfc2307bis',
      'default_shell'                  => '/bin/bash',
      'ldap_uri'    => hiera('sssd::config:domain/malariagen:ldap_uri', [ 'ldap://192.168.9.1/' ]),
      'ldap_default_bind_dn'    => hiera('sssd::config:domain/malariagen:ldap_default_bind_dn', 'cn=admin,dc=malariagen,dc=net'),
      'ldap_default_authtok'    => hiera('sssd::config:domain/malariagen:ldap_default_authtok', 'password'),
      'ldap_search_base'    => hiera('sssd::config:domain/malariagen:ldap_search_base', 'dc=malariagen,dc=net')

    }
  }
} ->
file { "/etc/ssh/ldap-keys.sh":
    mode => 700,
    owner => root,
    group => root,
    source => "puppet:///modules/malariagen/ldap-keys.sh"
} ->
class { 'ssh':
  storeconfigs_enabled => false,
  server_options => {
		'PasswordAuthentication' => 'no',
		'PubkeyAuthentication' => 'yes',
		'AuthorizedKeysFile' =>	'%h/.ssh/authorized_keys',
		'AuthorizedKeysCommand' => '/etc/ssh/ldap-keys.sh',
		'AuthorizedKeysCommandUser' => 'root'
  }
}
