class profile::cluster::mount(
    $users,
    $level1,
    $level2,
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


    $users.each |String $user| {
        nfs::client::mount{ "/home/${user}":
            server => $home_server,
            share => "/homes/${user}",
            ensure  => 'mounted',
            options_nfs => $nfs_options
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
