#!/bin/sh

#Source the profile script, to set SGE_ROOT, etc.
# Otherwise, set it by hand.
. 

# Alter as needed.
TMPDIR=./SGE_BACKUP.$SGE_CELL.`date "+%Y%m%d"`
mkdir -p $TMPDIR
cd $TMPDIR

set -C

function log {
    echo "Backing up [$*]"
}

# Backups the queues
for queue in `qconf -sql`; do 
    qconf -sq $queue > queue_$queue
    log queue $queue
done

for hostgroup in `qconf -shgrpl`; do
    qconf -shgrp_tree $hostgroup > hostgroup_${hostgroup/@/}
    log hostgroup  $hostgroup
done

#And the default queue
log queue default
qconf -sq > queue_default

log cluster configuration
qconf -sconf > cluster_conf

log scheduler configuration
qconf -ssconf > sched_conf

log complexes
qconf -sc > complexes

log sharetree
qconf -sstree > share_tree

log usersets
qconf -sul | sort > userset_list

log users
qconf -suserl | sort > user_list

log managers
qconf -sm | sort > manager_list

log operators
qconf -so | sort > operator_list

log RQS 
qconf -srqs > resource_quotas

for pe in `qconf -spl`; do 
    log PE $pe
	qconf -sp $pe > pe_$pe
done

for project in `qconf -sprjl`; do 
    log project $project
	qconf -sprj $project > project_$project
done

for su in `qconf -sul`; do 
    log user list $su
	qconf -su $su > ul_$su
done

for e in `qconf -sel`; do 
    log exec host $e
	qconf -se $e > exec_$e
done

log exec host global
qconf -se global > exec_global
