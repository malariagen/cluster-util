
class { '::etckeeper':
  vcs => 'git',
}

include sudo
#include sso_ldap_client

#include mail

hiera_include('classes')

node default {
}

node sierra.well.ox.ac.uk {

        include elk_server

}

node 'sso-dev.cggh.org' {

#        class { 'tomcat_server' :
#            user => 'tomcat7',
#        }

        class { 'filebeat':
                major_version => '5',
                outputs => {
                    'logstash'     => {
                     'hosts' => [
                       'localhost:5044',
                     ],
                    },
                },
                prospectors_merge => true,
                prospectors => lookup('filebeat::prospector', Hash, { strategy => 'deep' }, {}),
        }

        filebeat::prospector { 'syslogs':
          paths    => [
            '/var/log/auth.log',
            '/var/log/syslog',
          ],
          tags => [ 'syslogs'],
          doc_type => 'syslog-beat',
        }


}
