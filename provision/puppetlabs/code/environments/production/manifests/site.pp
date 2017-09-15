
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

node 'delta.well.ox.ac.uk','echo.well.ox.ac.uk','foxtrot.well.ox.ac.uk','golf.well.ox.ac.uk','hotel.well.ox.ac.uk','india.well.ox.ac.uk','juliet.well.ox.ac.uk','kilo.well.ox.ac.uk','lima.well.ox.ac.uk','mike.well.ox.ac.uk','november.well.ox.ac.uk','romeo.well.ox.ac.uk' {
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
