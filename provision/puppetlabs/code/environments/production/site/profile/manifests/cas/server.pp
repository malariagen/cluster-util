# Class: profile::cas::server
# ===========================
#
# Full description of class profile::cas::server here.
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
class profile::cas::server(
     Optional[String] $uri  = 'https://localhost:8443',
     Optional[String] $context  = 'sso',
     Optional[Tuple] $ldap_uri  = lookup('profile::ldap::client::ldap_uri', { default_value => [ 'ldap://localhost/' ] } ),
     Optional[String] $base_dn  = lookup('profile::ldap::client::ldap_default_base_dn', { default_value => 'dc=malariagen,dc=net'} ),
     Optional[String] $bind_dn  = lookup('profile::ldap::client::ldap_default_bind_dn', { default_value => 'cn=admin,dc=malariagen,dc=net'} ),
     Optional[String] $authtok  = lookup('profile::ldap::client::ldap_default_authtok', { default_value => 'password'} ),
     Optional[String] $lookup  = lookup('profile::ldap::client::lookup', { default_value => 'cn=%s,ou=users,ou=people,dc=malariagen,dc=net'} ),
     Optional[String] $ldap_search_base  = lookup('profile::ldap::client::ldap_search_base', { default_value => 'dc=malariagen,dc=net'} ),
     Optional[String] $user_filter = 'mail={user}',
     Optional[String] $owner  = lookup('profile::tomcat::user', { default_value => 'tomcat8'} ),
     Optional[Tuple] $admin_users  = ['ian.wright@well.ox.ac.uk'],
     Optional[String] $log_directory  = lookup('profile::tomcat::log_directory', { default_value => '/var/log/tomcat8'} ),
     Optional[String] $service_def_base_dn = 'ou=cas,ou=system,dc=malariagen,dc=net',
     String  $tgc_encryption_key,
     String  $tgc_signing_key,
     String  $webflow_encryption_key,
     String  $webflow_signing_key,
     String  $clearpass_encryption_key,
     String  $clearpass_signing_key,

) {


	file { "/etc/cas":
	    mode => "0700",
	    owner => $owner,
	    group => $owner,
        ensure => 'directory',
    } ->
	file { "/etc/cas/config":
	    mode => "0700",
	    owner => $owner,
	    group => $owner,
        ensure => 'directory',
    } ->
	file { "/etc/cas/config/cas.properties":
	    mode                                                                                => "0600",
	    owner                                                                               => $owner,
	    group                                                                               => $owner,
	    content                                                                             => epp('profile/cas/server/cas.properties.epp', { 'cas_server_name' => $uri,
                                                                    'context'               => $context,
                                                                    'ldap_url'              => $ldap_uri,
                                                                    'ldap_manager_userdn'   => $bind_dn,
                                                                    'ldap_manager_password' => $authtok,
                                                                    'ldap_authn_format'     => $lookup,
                                                                    'ldap_base_dn'          => $base_dn,
                                                                    'ldap_search_filter'    => $ldap_search_base,
                                                                    'user_filter'           => $user_filter,
                                                                    'service_def_base_dn'   => $service_def_base_dn,
                                                                    'tgc_encryption_key'    => $tgc_encryption_key,
                                                                    'tgc_signing_key'       => $tgc_signing_key,
                                                                    'webflow_encryption_key'    => $webflow_encryption_key,
                                                                    'webflow_signing_key'       => $webflow_signing_key,
                                                                    'clearpass_encryption_key'    => $clearpass_encryption_key,
                                                                    'clearpass_signing_key'       => $clearpass_signing_key,

                                                                    })

	} -> 
	file { "/etc/cas/config/management.properties":
	    mode => "0600",
	    owner => $owner,
	    group => $owner,
	    content => epp('profile/cas/management/management.properties.epp', { 'cas_server_name' => $uri,
                                                                    'context' => $context,
                                                                    'service_def_base_dn'   => $service_def_base_dn,
                                                                    'user_filter'           => $user_filter,
                                                                    'ldap_url'              => $ldap_uri,
                                                                    'ldap_manager_userdn'   => $bind_dn,
                                                                    'ldap_manager_password' => $authtok,
                                                              })
  } ->
	file { "/etc/cas/config/users.properties":
	    mode => "0600",
	    owner => $owner,
	    group => $owner,
	    content => epp('profile/cas/management/users.properties.epp', { 'admin_users' => $admin_users,
                                                              })
  } ->
	file { "/etc/cas/config/log4j2-management.xml":
	    mode => "0600",
	    owner => $owner,
	    group => $owner,
	    content => epp('profile/cas/management/log4j2-management.xml.epp', { 'log_directory' => $log_directory,
                                                              })
  } ->
	file { "/etc/cas/config/log4j2.xml":
	    mode => "0600",
	    owner => $owner,
	    group => $owner,
	    content => epp('profile/cas/server/log4j2.xml.epp', { 'log_directory' => $log_directory,
                                                              })
  }

}
