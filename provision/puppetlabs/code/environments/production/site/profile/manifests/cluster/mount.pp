class profile::cluster::mount(
    $users,
    $level1,
    $level2,
	Optional[Tuple] $smb_mounts = undef,
    Optional[String] $home_server = 'papa.well.ox.ac.uk',
    Optional[String] $level1_server = 'papa.well.ox.ac.uk',
    Optional[String] $level2_server = 'papa.well.ox.ac.uk',
) {


    $nfs_options = "auto,nofail,noatime,nolock,intr,tcp,actimeo=1800,rsize=32768,wsize=32768"


    class { '::nfs':
          client_enabled => true,
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
            require => [ Package["cifs-utils"] ],
	}

	if $smb_mounts {
		$smb_mounts.each |$mount| {

			$credfile = "${cred_dir}/${mount['user']}"

			
			if $mount[ensure] {
				$mount_status = "${mount['ensure']}"
			} else {
				$mount_status = "mounted"
			}
			$default_options = "iocharset=utf8,${mount['options']}"
			if $mount[pass] {
				file { $credfile:
					owner   => root,
					group   => root,
					mode    => '0644',
					ensure  => present,
					content =>  "user=${mount['user']}\npass=${mount['pass']}\n",
                    require => [ File["${cred_dir}"] ],
				}
				$options = "$default_options,credentials=$credfile"
			} else {
				$options = "$default_options,user=${mount['user']}"
			}
			file {"${mount['path']}":
				owner => "${mount['user']}",
				ensure => directory,
				mode => '0755'
			}

			mount {"${mount['path']}":
				device => "${mount['device']}",
				atboot => "false",
				ensure => $mount_status,
				fstype => "cifs",
				options => $options,
				require => [ File["${mount['path']}"] ],
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
