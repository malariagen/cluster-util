class profile::cluster::master(
    $ident,
    $packages,
    $submit_nodes,
    $queues,
    $parallel_envs,
    $acls,
    $hostgroups,
    $users,
    $managers,
    $projects,
    $sconf,
    $quotas
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


    $projects.each |$prj| {

        $prjdefn = "/tmp/${prj['name']}_prj"

        $exec_name = "configure prj ${prj['name']}"

        file { $prjdefn:
            ensure => file,
            content => epp('profile/cluster_master/project.epp', { 'prj_name' => $prj[name] }),
            notify => Exec["$exec_name"]
        }

        exec { "$exec_name":
            command => "/usr/bin/qconf -Mprj $prjdefn || /usr/bin/qconf -Aprj $prjdefn"
        }

    }


    $users.each |$user| {

        $userdefn = "/tmp/${user['name']}_user"

        $exec_name = "configure user ${user['name']}"

        file { $userdefn:
            ensure => file,
            content => epp('profile/cluster_master/user.epp', { 'user_name' => $user[name], 'default_project' => $user[project] }),
            notify => Exec["$exec_name"]
        }

        exec { "$exec_name":
            command => "/usr/bin/qconf -Muser $userdefn || /usr/bin/qconf -Auser $userdefn"
        }

    }

    $quotas.each |$quota| {

        $quotadefn = "/tmp/${quota['name']}_rqs"

        $exec_name = "configure quota ${quota['name']}"

        file { $quotadefn:
            ensure => file,
            content => epp('profile/cluster_master/quota.epp', { 
                            'rqs_name' => $quota[name],
                            'rqs_description' => $quota[description],
                            'rqs_enabled' => $quota[enabled],
                            'rqs_limit' => $quota[limit],
                            }),
            notify => Exec["$exec_name"]
        }

        exec { "$exec_name":
            command => "/usr/bin/qconf -Mrqs $quotadefn || /usr/bin/qconf -Arqs $quotadefn"
        }

    }

    $managers.each |$manager| {

        $exec_name = "configure manager ${manager}"

        exec { "$exec_name":
            command => "/usr/bin/qconf -sm | grep ${manager} || /usr/bin/qconf -am ${manager}"
        }

    }

    $acls.each |$ul| {

        $uldefn = "/tmp/${ul['name']}_ul"

        $exec_name = "configure acl ${ul['name']}"

        file { $uldefn:
            ensure => file,
            content => epp('profile/cluster_master/ul.epp', { 'ul_name' => $ul[name], 'entries' => $ul[entries].join(',') }),
            notify => Exec["$exec_name"]
        }

        exec { "$exec_name":
            command => "/usr/bin/qconf -Mu $uldefn || /usr/bin/qconf -Au $uldefn"
        }

    }
    $hostgroups.each |$hostgroup| {

        $hostgroup_defn = "/tmp/${hostgroup['name']}_hostgroup"

        $exec_name = "configure hostgroup ${hostgroup['name']}"

        file { $hostgroup_defn:
            ensure => file,
            content => epp('profile/cluster_master/hostgroup.epp', { 'group_name' => $hostgroup[name], 'hostlist' => $hostgroup[hosts].join(' ') }),
            notify => Exec["$exec_name"]
        }

        exec { "$exec_name":
            command => "/usr/bin/qconf -Mhgrp $hostgroup_defn || /usr/bin/qconf -Ahgrp $hostgroup_defn"
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

    $sconfdefn = "/tmp/sconf"

    $exec_name = "configure cluster"
    file { $sconfdefn:
            ensure => file,
            content => epp('profile/cluster_master/sconf.epp', { 
                'schedule_interval' => $sconf[schedule_interval],
                'flush_submit_sec' => $sconf[flush_submit_sec],
                'flush_finish_sec' => $sconf[flush_finish_sec],
                'weight_tickets_share' => $sconf[weight_tickets_share],
                'weight_ticket' => $sconf[weight_ticket],
                'weight_urgency' => $sconf[weight_urgency],
                'weight_priority' => $sconf[weight_priority],
                'max_reservation' => $sconf[max_reservation]
            }),
            notify => Exec["$exec_name"]
    }

    exec { "$exec_name":
        command => "/usr/bin/qconf -Msconf $sconfdefn"
    }

}

