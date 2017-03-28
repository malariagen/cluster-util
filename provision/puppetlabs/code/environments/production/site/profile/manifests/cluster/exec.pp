class profile::cluster::exec(
    Optional[String] $cluster_server = 'quebec.well.ox.ac.uk',
) {

    $hosts = lookup ("profile::cluster::common::master")
    $hosts.each |$host| {
         host { $host["name"]:
           ensure       => 'present',
           ip           => $host[ip],
           host_aliases           => $host[aliases],
         }
    }

    $nfs_options = "rw,rsize=32768,wsize=32768,intr,noatime,nfsvers=3,soft,bg,actimeo=0,timeo=600"


	package { "gridengine-exec":
	}
	package { "gridengine-client":
	}

    nfs::client::mount{ '/var/lib/gridengine/default':
        server => $cluster_server,
        ensure  => 'mounted',
        options_nfs => $nfs_options,
		require => [ Package['gridengine-client'], Package['gridengine-client'] ]
    }
}
