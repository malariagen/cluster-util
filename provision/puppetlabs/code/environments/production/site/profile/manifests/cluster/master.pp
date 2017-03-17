class profile::cluster::master(
    $ident,
    $packages,
) {

    $packages.each |$package| {
        package { $package["name"] :
            ensure => $package["version"]
        }
    }

    #This isn't required as it will be done when the package is installed like this
    #The init_cluster script will exit if it has already been done
    #Left for documentation purposes
    #exec { "init":
    #    command => "sudo -u sgeadmin /usr/share/gridengine/scripts/init_cluster /var/lib/gridengine default /var/spool/gridengine/spooldb sgeadmin"
    #}

    class { '::nfs':
        server_enabled => true
    }

    nfs::server::export{ '/var/lib/gridengine/default':
        ensure  => 'mounted',
        clients => '@kwiat-cluster-nodes(rw,subtree_check)'
    }
}

