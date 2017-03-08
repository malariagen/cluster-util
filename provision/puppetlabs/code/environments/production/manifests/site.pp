
class { '::etckeeper':
  vcs => 'git',
}

include sudo
include sso_ldap_client

include mail

hiera_include('classes')

node default {
}

node sierra.well.ox.ac.uk {
        postfix::config {
                'header_checks': value => 'regexp:/etc/postfix/header_checks'
        }
        $header_checks = lookup({ 'name' => 'config::header_checks'})
        file {
                '/etc/postfix/header_checks':
                content => "${header_checks}"
        }
        

        include elk_server

}

node 'sso-dev.cggh.org' {

        class { 'filebeat':
		outputs => {
		    'logstash'     => {
		     'hosts' => [
		       'localhost:5044',
		     ],
		    },
		},
		prospectors => hiera_hash('filebeat::prospector'),
        }

        filebeat::prospector { 'syslogs':
          paths    => [
            '/var/log/auth.log',
            '/var/log/syslog',
          ],
          doc_type => 'syslog-beat',
        }

}
