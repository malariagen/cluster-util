class profile::ssl::default(
    String $server_key_directory,
    String $server_key_group,
    String $server_key,
    String $server_key_location,
    String $server_cert_location,
    String $server_cert,
    String $ca_cert_location,
    String $ca_cert,
    Optional[String] $cert_reader = undef,
) {

    group { $server_key_group:
        ensure => 'present',
        gid => 115
    }

    file { $server_key_directory:
        owner => 'root', 
        group => $server_key_group,
        mode => '0710'
    }

    file { $server_key_location:
        owner => 'root', 
        group => $server_key_group,
        mode => '0640' ,
        content => $server_key
    }

    file { $server_cert_location:
        owner => 'root', 
        group => 'root',
        mode => '0644' ,
        content => $server_cert
    }
    file { $ca_cert_location:
        owner => 'root', 
        group => 'root',
        mode => '0644' ,
        content => $ca_cert
    }

    if $cert_reader {
       @user { $cert_reader:
          groups     => [ $server_key_group ],
          membership => minimum # default
        }

        realize User[$cert_reader]
    }
}
