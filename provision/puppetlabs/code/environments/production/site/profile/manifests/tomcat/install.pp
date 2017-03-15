class profile::tomcat::install inherits profile::tomcat::server {

        #Something of a bodge - fact won't be set on first run by the module, but value will be picked up afterwards
        file { '/opt/puppetlabs/facter/facts.d/tomcat_server.yaml':
                content => template('profile/facts/tomcat_server.yaml.erb'),
                owner => root,
                mode => '0500',
        }

        class { 'tomcat':
                version => $version,
				package_name => $package,
#You can use this if you want a value for minimumUmask in the SecurityListener
#                java_opts => ['-server', '-Dorg.apache.catalina.security.SecurityListener.UMASK=`umask`', '-Djava.awt.headless=true', '-Xmx128m', '-XX:+UseConcMarkSweepGC'],
                versionlogger_listener => false,
                apr_listener => true,
                listeners => [
                                { 'className' => 'org.apache.catalina.security.SecurityListener', 'minimumUmask' => '' }
                        ],
                http_uriencoding => 'UTF-8',
                ajp_connector => true,
                ajp_port => 8009,
                ajp_uriencoding => 'UTF-8',
                ajp_params => { },
                ssl_connector => true,
                ssl_uriencoding => 'UTF-8',
                ssl_protocol => 'org.apache.coyote.http11.Http11AprProtocol',
                ssl_params => $ssl_params,
                accesslog_valve => false,
                valves => [
                                { 'className' => 'org.apache.catalina.valves.AccessLogValve',
                                  'directory' => 'logs',
                                  'prefix' => 'access-',
                                  'suffix' => '.log',
                                  'pattern' => '%a %l %u %t "%r" %s %b "%{Referer}i" "%{User-agent}i" %D "%I"',
                                  'resolveHosts' => 'false'
                                }
                          ]
        }
}
