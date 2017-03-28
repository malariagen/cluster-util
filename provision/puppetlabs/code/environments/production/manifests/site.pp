
class { '::etckeeper':
  vcs => 'git',
}

include sudo
#include sso_ldap_client

#include mail

hiera_include('classes')

node default {
}

node 'sierra.well.ox.ac.uk' {

        include elk_server

}

node 'echo.well.ox.ac.uk' {
    $role = "---

role: 'cluster_worker'
"

    file { '/opt/puppetlabs/facter/facts.d/role.yaml':
                content => $role,
                owner => root,
                mode => '0500',
    }
}

node 'quebec.well.ox.ac.uk' {
     $role = "---

role: 'cluster_master'
"
 
     file { '/opt/puppetlabs/facter/facts.d/role.yaml':
                 content => $role,
                 owner => root,
                 mode => '0500',
     }
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
