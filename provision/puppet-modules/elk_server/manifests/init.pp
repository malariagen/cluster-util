# Class: elk_server
# ===========================
#
# Full description of class elk_server here.
#
# Parameters
# ----------
#
# Document parameters here.
#
# * `sample parameter`
# Explanation of what this parameter affects and what it defaults to.
# e.g. "Specify one or more upstream ntp servers as an array."
#
# Variables
# ----------
#
# Here you should define a list of variables that this module would require.
#
# * `sample variable`
#  Explanation of how this variable affects the function of this class and if
#  it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#  External Node Classifier as a comma separated list of hostnames." (Note,
#  global variables should be avoided in favor of class parameters as
#  of Puppet 2.6.)
#
# Examples
# --------
#
# @example
#    class { 'elk_server':
#      servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#    }
#
# Authors
# -------
#
# Author Name <author@domain.com>
#
# Copyright
# ---------
#
# Copyright 2017 Your name here, unless otherwise noted.
#
class elk_server {

	#autoupgrade not really a good idea...
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
	  content => template('elk_server/logstash_conf.erb'),
	}

	logstash::plugin { 'logstash-input-beats': }
	logstash::plugin { 'logstash-filter-grok': }
	logstash::plugin { 'logstash-filter-mutate': }


	include ::kibana
}
