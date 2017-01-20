sudo apt-get install puppet-common
for i in sgnl05-sssd saz/ssh
do
  puppet module install $i -i ./modules
done
