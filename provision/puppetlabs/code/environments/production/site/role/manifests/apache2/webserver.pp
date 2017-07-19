class role::apache2::webserver {
    include profile::base
    include profile::server
    include profile::apache2::proxy
}
