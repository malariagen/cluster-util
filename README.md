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

