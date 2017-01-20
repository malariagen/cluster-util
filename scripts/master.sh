DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

${DIR}/dependencies.sh

# Configure the master hostname for Grid Engine
echo "gridengine-master       shared/gridenginemaster string  $HOSTNAME" | sudo debconf-set-selections
echo "gridengine-master       shared/gridenginecell   string  default" | sudo debconf-set-selections
echo "gridengine-master       shared/gridengineconfig boolean false" | sudo debconf-set-selections
echo "gridengine-common       shared/gridenginemaster string  $HOSTNAME" | sudo debconf-set-selections
echo "gridengine-common       shared/gridenginecell   string  default" | sudo debconf-set-selections
echo "gridengine-common       shared/gridengineconfig boolean false" | sudo debconf-set-selections
echo "gridengine-client       shared/gridenginemaster string  $HOSTNAME" | sudo debconf-set-selections
echo "gridengine-client       shared/gridenginecell   string  default" | sudo debconf-set-selections
echo "gridengine-client       shared/gridengineconfig boolean false" | sudo debconf-set-selections

# Install Grid Engine
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y gridengine-master gridengine-client

# Set up Grid Engine
sudo -u sgeadmin /usr/share/gridengine/scripts/init_cluster /var/lib/gridengine default /var/spool/gridengine/spooldb sgeadmin
sudo service gridengine-master restart

#http://www.softpanorama.org/HPC/Grid_engine/Installation/installation_of_master_host.shtml

sudo DEBIAN_FRONTEND=noninteractive apt-get install -y nfs-kernel-server

grep gridengine /etc/exports || echo "/var/lib/gridengine/default @kwiat-cluster-nodes(rw,subtree_check)" >> /etc/exports
${DIR}/software.sh
grep local /etc/exports || echo "/usr/local @kwiat-cluster-nodes(rw,subtree_check)" >> /etc/exports
sudo exportfs -a
exit 0
