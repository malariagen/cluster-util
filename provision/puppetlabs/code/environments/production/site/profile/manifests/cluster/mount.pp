class profile::cluster::mount(
    $users,
    $level1,
    $level2,
	Optional[Tuple] $smb_mounts = undef,
    Optional[String] $home_server = 'papa.well.ox.ac.uk',
    Optional[String] $level1_server = 'papa.well.ox.ac.uk',
    Optional[String] $level2_server = 'papa.well.ox.ac.uk',
    Optional[String] $cluster_server = 'quebec.well.ox.ac.uk',
) {


    $nfs_options = "rw,rsize=32768,wsize=32768,intr,noatime,nfsvers=3,soft,bg,actimeo=0,timeo=600"


    class { '::nfs':
          client_enabled => true,
    }

    nfs::client::mount{ '/var/lib/gridengine/default':
        server => $cluster_server,
        ensure  => 'mounted',
        options_nfs => $nfs_options
    }


    $users.each |$user| {
        $u = "${user['name']}"
        nfs::client::mount{ "/home/${u}":
            server => $home_server,
            share => "/homes/${u}",
            ensure  => 'mounted',
            options_nfs => $nfs_options
        }
    }

	package { 'cifs-utils':
	}

	#For utf8
	package { 'linux-image-extra-virtual':
		install_options => '--no-install-recommends'
	}

	$cred_dir = "/etc/samba/creds"
	file { $cred_dir:
			owner   => root,
			group   => root,
			mode    => '0700',
			ensure  => directory,
	}

	if $smb_mounts {
    $smb_mounts.each |$mount| {

			$credfile = "${cred_dir}/${mount['user']}"
			file { $credfile:
				owner   => root,
				group   => root,
				mode    => '0644',
				ensure  => present,
				content =>  "user=${mount['user']}\npass=${mount['pass']}\n",
			}

			file {"${mount['path']}":
				owner => "${mount['user']}",
				ensure => directory,
				mode => '0755'
			}

			mount {"${mount['path']}":
				device => "${mount['device']}",
				atboot => "false",
				ensure => "mounted",
				fstype => "cifs",
				options => "iocharset=utf8,${mount['options']},credentials=$credfile",
				require => [ File[$credfile], File["${mount['path']}"] ],
			}
		}
	}

    $level1.each |String $dir| {
        nfs::client::mount{ "/kwiat/1/${dir}":
            server => $level1_server,
            ensure  => 'mounted',
            options_nfs => $nfs_options
        }
    }

    $level2.each |String $dir| {
        nfs::client::mount{ "/kwiat/2/${dir}":
            server => $level2_server,
            ensure  => 'mounted',
            options_nfs => $nfs_options
        }
    }
}
