#autoupgrade not really a good idea...

node 'sierra.well.ox.ac.uk' {
class { 'elasticsearch':
  java_install => true,
  manage_repo  => true,
  autoupgrade => true,
  repo_version => '5.x',
}

elasticsearch::instance { 'es-01': }
elasticsearch::plugin { 'x-pack': instances => 'es-01' }

include logstash

# You must provide a valid pipeline configuration for the service to start.
logstash::configfile { 'my_ls_config':
  content => template('malariagen/logstash_conf.erb'),
}

logstash::plugin { 'logstash-input-beats': }
logstash::plugin { 'logstash-filter-grok': }
logstash::plugin { 'logstash-filter-mutate': }
}
