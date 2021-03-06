class profile::cluster::master(
    $ident,
    $packages,
    $submit_nodes,
    $queues,
    $parallel_envs,
    $acls,
    $exec_hosts,
    $hostgroups,
    $users,
    $managers,
    $projects,
    $sconf,
    $quotas,
    $cluster_conf,
    $share_tree
) {

    $hosts = lookup ("profile::cluster::common::master")
    $hosts.each |$host| {
         host { $host["name"]:
           ensure       => 'present',
           ip           => $host[ip],
           host_aliases           => $host[aliases],
         }
    }

    $workers = lookup ("profile::cluster::common::workers")
    $workers.each |$worker| {
         host { $worker["name"]:
           ensure       => 'present',
           ip           => $worker[ip],
           host_aliases           => $worker[aliases],
         }
    }

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

    $clients = $workers.reduce([]) | $memo, $value | {
        concat($memo,"${value[ip]}(rw,subtree_check)") 
    }

    nfs::server::export{ '/var/lib/gridengine/default':
        ensure  => 'mounted',
        clients => $clients.join(" ")
    }

    $submit_nodes.each |$node| {
        exec { "submit nodes ${node}":
            command => "/usr/bin/qconf -as $node"
        }
    }

    $parallel_envs.each |$pe| {

        $pedefn = "/tmp/${pe['name']}"

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
            command => "/usr/bin/qconf -Mrqs $quotadefn ${quota['name']} || /usr/bin/qconf -Arqs $quotadefn ${quota['name']} "
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

    $exec_hosts.each |$exechost| {

        $exechost_defn = "/tmp/${exechost['name']}_exechost"

        $exec_name = "configure exechost ${exechost['name']}"

        file { $exechost_defn:
            ensure => file,
            content => epp('profile/cluster_master/exec_host.epp', { 
                            'exec_host_name' => $exechost[name],
                            'complex_values' => $exechost[complex_values]
                            }),
            notify => Exec["$exec_name"]
        }

        exec { "$exec_name":
            command => "/usr/bin/qconf -Me $exechost_defn || /usr/bin/qconf -Ae $exechost_defn"
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

        $s = ["${queue['default_slots']}"]
        if $queue['slots'] {
            $slots = $queue[slots].reduce($s) | $memo, $value | {
                concat($memo, "[${value[host]}=${value[num]}]") 
            }
        } else {
            $slots = $s
        }
        file { $qdefn:
            ensure => file,
            content => epp('profile/cluster_master/queue.epp', { 
                                                        'queue_name' => $queue[name],
                                                        'hostlist' => $queue[hostlist],
                                                        'seq_no' => $queue[seq_no],
                                                        'load_thresholds' => $queue[load_thresholds],
                                                        'user_lists' => $queue[user_lists],
                                                        'owner_list' => $queue[owner_list],
                                                        'complex_values' => $queue[complex_values],
                                                        'subordinate_list' => $queue[subordinate_list],
                                                        'slots' => $slots.join(','),
                                                        'pe_list' => $queue[pe_list]
                                                        }),
            notify => Exec["$exec_name"]
        }

        exec { "$exec_name":
            command => "/usr/bin/qconf -Mq $qdefn || /usr/bin/qconf -Aq $qdefn"
        }

    }

    $sconfdefn = "/tmp/sconf"

    $exec_name = "configure schedule"
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


    #This name has to be global
    $confdefn = "/tmp/global"

    $confexec_name = "configure cluster"
    file { $confdefn:
            ensure => file,
            content => epp('profile/cluster_master/cluster_conf.epp', { 
                'enforce_project' => $cluster_conf[enforce_project],
                'administrator_mail' => $cluster_conf[administrator_mail],
                'qmaster_params' => $cluster_conf[qmaster_params],
                'execd_params' => $cluster_conf[execd_params],
                'max_aj_instances' => $cluster_conf[max_aj_instances],
                'max_aj_tasks' => $cluster_conf[max_aj_tasks],
            }),
            notify => Exec["$confexec_name"]
    }

    exec { "$confexec_name":
        command => "/usr/bin/qconf -Mconf $confdefn"
    }


    $cconfdefn = "/tmp/cconf"

    $cexec_name = "configure complexes"
    file { $cconfdefn:
            ensure => file,
            content => epp('profile/cluster_master/complexes.epp', { 
            }),
            notify => Exec["$cexec_name"]
    }

    exec { "$cexec_name":
        command => "/usr/bin/qconf -Mc $cconfdefn"
    }

    file { '/var/lib/gridengine/default/common/sge_request':
            ensure => file,
            content => epp('profile/cluster_master/sge_request.epp', { 
            })
    }


    $tree_defn = "/tmp/share_tree"

    $tree_exec_name = "configure share tree"

    file { $tree_defn:
        ensure => file,
        content => epp('profile/cluster_master/node.epp', {
                                                            'nodes' => $share_tree[nodes]
                                                        }),
        notify => Exec["$tree_exec_name"]
    }

    exec { "$tree_exec_name":
        command => "/usr/bin/qconf -Mstree $tree_defn || /usr/bin/qconf -Astree $tree_defn"
    }

}

