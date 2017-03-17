# cluster-util

## To test 

Install vagrant and the vagrant-hostmanager and trigger plugins *vagrant plugin install vagrant-hostmanager*

Go to *provision/vagrant***

*vagrant up* will start the machine(s) and install puppet configured to the appropriate role

Test specific configuration is in *provision/puppetlabs/code/environments/production/data/location/virtualbox/common.yaml*

### To test via vagrant

Run *vagrant provision* with an optional parameter of the vm hostjjname

### To test on the VM

SSH to the box using *vagrant ssh vm.hostname*

Create a fact to define the role (done in the provisioner if using *vagrant provision* instead) by creating */opt/puppetlabs/facter/facts.d/role.yaml*

```
---

role: 'cluster_master'
```

You can then run locally *puppet apply -t -d /etc/puppetlabs/code/environments/production/manifests/site.pp*

## LDAP

For test instances using LDAP e.g. cluster you need a local LDAP - see *malariagen-cas/util/provision/packer* with worker1, worker2 in the cn=kwiat-cluster-nodes,ou=netgroups,ou=system,dc=malariagen,dc=net nisNetgroup

Test with *getent netgroup kwiat-cluster-nodes* or *ldapsearch -H ldap://10.0.2.2/ -x -D "cn=admin,dc=malariagen,dc=net" -wpassword "(cn=kwiat-cluster-nodes)" -b dc=malariagen,dc=net*
