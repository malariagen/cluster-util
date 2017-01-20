#Note that the instance type is only used during creation of the AMI so can be a t1.micro - you set the actual values
#when launching an instance based off that AMI
packer build -only qemu xenial-master.json
