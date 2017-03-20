class profile::cluster::master(
    $ident,
    $packages,
    $submit_nodes,
    $queues,
    $parallel_envs,
    $acls
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
    $submit_nodes.each |$node| {
        exec { "submit nodes":
            command => "/usr/bin/qconf -as $node"
        }
    }

    $queues.each |$queue| {

        $qdefn = "/tmp/${queue['name']}.q"

        $exec_name = "configure queue ${queue['name']}"

        $slots = $queue[slots].reduce(["${queue['default_slots']}"]) | $memo, $value | {
            concat($memo, "[${value[host]}=${value[num]}]") 
        }
        file { $qdefn:
            ensure => file,
            content => epp('profile/cluster_master/queue.epp', { 'queue_name' => $queue[name],
            'slots' => $slots.join(','), 'pe_list' => $queue[pe_list] }),
            notify => Exec["$exec_name"]
        }

        exec { "$exec_name":
            command => "/usr/bin/qconf -Mq $qdefn || /usr/bin/qconf -Aq $qdefn"
        }

    }
    $parallel_envs.each |$pe| {

        $pedefn = "/tmp/${pe['name']}_pe"

        $exec_name = "configure parallel env ${pe['name']}"

        file { $pedefn:
            ensure => file,
            content => epp('profile/cluster_master/pe.epp', { 'pe_name' => $pe[name],
            'num_slots' => $pe[slots], 'rule' => $pe[rule], 'control_slaves' => $pe[control_slaves] }),
            notify => Exec["$exec_name"]
        }

        exec { "$exec_name":
            command => "/usr/bin/qconf -Mp $pedefn || /usr/bin/qconf -Ap $pedefn"
        }

    }

    $acls.each |$ul| {

        $uldefn = "/tmp/${ul['name']}_ul"

        $exec_name = "configure parallel env ${ul['name']}"

        file { $uldefn:
            ensure => file,
            content => epp('profile/cluster_master/ul.epp', { 'ul_name' => $ul[name],
            'entries' => $ul[entries].join(',') }),
            notify => Exec["$exec_name"]
        }

        exec { "$exec_name":
            command => "/usr/bin/qconf -Mu $uldefn || /usr/bin/qconf -Au $uldefn"
        }

    }
}

