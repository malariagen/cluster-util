class profile::ssl::default(
    String $server_key_directory,
    String $server_key_group,
    String $server_key,
    String $server_key_location,
    String $server_cert_location,
    String $server_cert,
    Optional[String] $ca_cert_location = undef,
    Optional[String] $ca_cert = undef,
    Optional[String] $cert_chain_location = undef,
    Optional[String] $cert_chain = undef,
    Optional[String] $cert_reader = undef,
) {

    group { $server_key_group:
        ensure => 'present',
        gid => 2000
    }

    file { $server_key_directory:
        owner => 'root', 
        group => $server_key_group,
        mode => '0750'
    }

    file { $server_key_location:
        owner => 'root', 
        group => $server_key_group,
        mode => '0640' ,
        content => $server_key
    }

    file { $server_cert_location:
        owner => 'root', 
        group => $server_key_group,
        mode => '0644' ,
        content => $server_cert
    }

    if $ca_cert_location {
        file { $ca_cert_location:
            owner => 'root', 
            group => $server_key_group,
            mode => '0644' ,
            content => $ca_cert
        }
    }

    if $cert_chain_location {
        file { $cert_chain_location:
            owner => 'root', 
            group => $server_key_group,
            mode => '0644' ,
            content => $cert_chain
        }
    }

    if $cert_reader {
         profile::ssl::user { "default_${cert_reader}":
                 cert_reader => $cert_reader
         }

    }
}
