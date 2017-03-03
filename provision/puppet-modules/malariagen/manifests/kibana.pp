node 'sierra.well.ox.ac.uk' {

include ::kibana

include apache::mod::authnz_ldap
  class { 'kibana::proxy::apache':
    ssl_port => 8443,
    ssl_ca   => "${::settings::ssldir}/certs/ca.pem",
    ssl_cert => "${::settings::ssldir}/certs/${::clientcert}.pem",
    ssl_key  => "${::settings::ssldir}/private_keys/${::clientcert}.pem",
    custom_fragment => "
    <Proxy *>
        Order Allow,Deny
        Allow from all
        AuthName 'we need your user and password'
        AuthType Basic
        AuthBasicProvider ldap
        AuthUserFile /dev/null
        AuthLDAPUrl ${sssd::config::domain::malariagen::ldap_uri}
        AuthLDAPBindDN ${sssd::config::domain::malariagen::ldap_default_bind_dn}
        AuthLDAPBindPassword ${sssd::config::domain::malariagen::ldap_default_authtok}
    </Proxy>"
  }
}
