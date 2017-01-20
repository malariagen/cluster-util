DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

${DIR}/dependencies.sh

echo "gridengine-common       shared/gridenginemaster string  $MASTER_HOSTNAME" | sudo debconf-set-selections
echo "gridengine-common       shared/gridenginecell   string  default" | sudo debconf-set-selections
echo "gridengine-common       shared/gridengineconfig boolean false" | sudo debconf-set-selections
echo "gridengine-client       shared/gridenginemaster string  $MASTER_HOSTNAME" | sudo debconf-set-selections
echo "gridengine-client       shared/gridenginecell   string  default" | sudo debconf-set-selections
echo "gridengine-client       shared/gridengineconfig boolean false" | sudo debconf-set-selections

DEBIAN_FRONTEND=noninteractive apt-get install -y gridengine-exec gridengine-client
#echo $MASTER_HOSTNAME | sudo tee /var/lib/gridengine/default/common/act_qmaster

DEBIAN_FRONTEND=noninteractive apt-get install -y nfs-common
for i in /var/lib/gridengine/default /usr/local
do
    grep $i /etc/fstab || echo "$MASTER_HOSTNAME:$i $i nfs  rw,soft,intr,tcp,rsize=32768,wsize=32768        1 2" >> /etc/fstab
done
mount -a
