
define profile::ssl::user(
    String $cert_reader,
) {

    $server_key_group = lookup('profile::ssl::default::server_key_group')
       @user { $cert_reader:
          groups     => [ $server_key_group ],
          membership => minimum # default
        }

        realize User[$cert_reader]
}
