class {'::sssd':
  config => {
    'sssd' => {
      'domains'             => 'malariagen',
      'config_file_version' => 2,
      'services'            => ['nss', 'pam'],
#      'services'            => ['nss', 'pam', 'ssh'],
    },
    'domain/malariagen' => {
      'cache_credentials'              => true,
      'id_provider'                    => 'ldap',
      'auth_provider'                    => 'ldap',
      'ldap_schema'                     => 'rfc2307bis',
      'default_shell'                  => '/bin/bash',
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
    content => epp('malariagen/ldap-keys_sh.epp', { 'login_filter' => lookup({ 'name' => 'config::domain::malariagen::ldap_login_filter', 'default_value' => ''})})
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
