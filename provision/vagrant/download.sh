wget http://arc.liv.ac.uk/downloads/SGE/releases/8.1.9/debian.tar.gz

for i in sge-common_8.1.9_all.deb sge-doc_8.1.9_all.deb sge_8.1.9_amd64.deb sge-dbg_8.1.9_amd64.deb
do
    wget http://arc.liv.ac.uk/downloads/SGE/releases/8.1.9/$i
done
