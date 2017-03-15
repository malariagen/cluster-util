class profile::server {

    include profile::ldap::client
    include profile::mail::relay
}
