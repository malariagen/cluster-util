class profile::apache2::proxy(
    Optional[Tuple] $proxy_pass = undef,
    Optional[Tuple] $jk_mounts = undef,
    Optional[String] $ssl_key = lookup( 'profile::ssl::default::server_key_location', { default_value => '/etc/ssl/certs/ssl-cert-snakeoil.pem'} ),
    Optional[String] $ssl_cert  = lookup( 'profile::ssl::default::server_cert_location', { default_value => '/etc/ssl/private/ssl-cert-snakeoil.key'} ),
    Optional[String] $ssl_ca  = lookup( 'profile::ssl::default::ca_cert_location', { default_value => '/etc/ssl/private/ssl-cert-snakeoil.key'} ),
    Optional[String] $user = 'apache2',
    Optional[String] $include_conf = undef,
    Optional[Tuple] $restricted = undef,
) {

# proxy_pass => [
#     { 'path' => '/a', 'url' => 'http://backend-a/' },
#     { 'path' => '/b', 'url' => 'http://backend-b/' },
#     { 'path' => '/c', 'url' => 'http://backend-a/c', 'params' => {'max'=>20, 'ttl'=>120, 'retry'=>300}},
#     { 'path' => '/l', 'url' => 'http://backend-xy',
#       'reverse_urls' => ['http://backend-x', 'http://backend-y'] },
#     { 'path' => '/d', 'url' => 'http://backend-a/d',
#       'params' => { 'retry' => '0', 'timeout' => '5' }, },
#     { 'path' => '/e', 'url' => 'http://backend-a/e',
#       'keywords' => ['nocanon', 'interpolate'] },
#     { 'path' => '/f', 'url' => 'http://backend-f/',
#       'setenv' => ['proxy-nokeepalive 1','force-proxy-request-1.0 1']},
#     { 'path' => '/g', 'url' => 'http://backend-g/',
#       'reverse_cookies' => [{'path' => '/g', 'url' => 'http://backend-g/',}, {'domain' => 'http://backend-g', 'url' => 'http:://backend-g',},], },
#     { 'path' => '/h', 'url' => 'http://backend-h/h',
#       'no_proxy_uris' => ['/h/admin', '/h/server-status'] },
#   ],
#

#  jk_mounts => [
#     { mount   => '/*',     worker => 'tcnode1', },
#     { unmount => '/*.jpg', worker => 'tcnode1', },
#   ],

    include apache

    include profile::ssl::default
    profile::ssl::user { 'apache2_ssl_user':
        cert_reader => $user
    }

    class { 'apache::mod::ssl':
        ssl_compression => true,
    }

    apache::vhost { "${hostname}":
        servername => $fqdn,
        serveradmin => 'sysadmin@malariagen.net',
        port            => '80',
        docroot         => '/var/www/redirect',
        redirect_status => 'permanent',
        redirect_dest   => "https://$hostname/",
    }

    apache::vhost { "${hostname}_ssl":
        servername => $fqdn,
        serveradmin => 'sysadmin@malariagen.net',
        port       => '443',
        docroot    => '/var/www/redirect',
        ssl        => true,
        proxy_preserve_host => true,
        ssl_proxyengine => true,
        ssl_key => $ssl_key,
        ssl_ca => $ssl_ca,
        ssl_cert => $ssl_cert,
        ssl_options => undef,
        proxy_pass => $proxy_pass,
        additional_includes => $include_conf,
        directories         => $restricted,
        jk_mounts => $jk_mounts
    }

}
