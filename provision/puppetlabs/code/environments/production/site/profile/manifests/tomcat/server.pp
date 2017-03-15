# == Class: tomcat
#
# Full description of class tomcat here.
#
# === Parameters
#
# Document parameters here.
#
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
#
# === Examples
#
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2017 Your name here, unless otherwise noted.
#
class profile::tomcat::server (
    #default values are in profile/functions/params.pp
    #These are equivalent to lookup('profile::jenkins::jenkins_port', {value_type => String, default_value => '9091'})
    Optional[String] $version = undef,
    Optional[String] $package = 'tomcat7',
    Optional[String] $user = 'tomcat7',
    $ssl_params = {
        'SSLCertificateKeyFile' => lookup( 'profile::ssl::default::server_key_location', { default_value => '/etc/ssl/certs/ssl-cert-snakeoil.pem'} ),
        'SSLCertificateFile' => lookup( 'profile::ssl::default::server_cert_location', { default_value => '/etc/ssl/private/ssl-cert-snakeoil.key'} ),
    },
    Optional[String] $ssl_group  = lookup( 'profile::ssl::default::server_key_group', { default_value => 'ssl-cert' }),
    Optional[Boolean] $install_java = true
) {

    include profile::ssl::default

    profile::ssl::user { 'tomcat_ssl_user':
        cert_reader => $user
    }

    contain profile::tomcat::install

    if $install_java { include profile::java::tomcat7 }
}
