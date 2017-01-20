apt install bsd-mailx db5.3-util libfontenc1 libhwloc-plugins libhwloc5 libjemalloc1 liblockfile-bin liblockfile1 libmotif-common libmunge2 libxaw7 libxcb-shape0 libxft2 libxm4 libxmu6 libxpm4 libxv1 libxxf86dga1 ocl-icd-libopencl1 postfix ssl-cert x11-utils xbitmaps xterm

if [ 0 = 1 ]
then
    apt install csh
    apt install openjdk-8-jdk
    apt install build-essential
    apt install ant
    cd sge-8.1.9/source/
    sh scripts/bootstrap.sh && ./aimk
else
    dpkg -i sge_8.1.9_amd64.deb sge-common_8.1.9_all.deb sge-doc_8.1.9_all.deb
    export PATH=$PATH:/opt/sge/bin/lx-amd64/
    export SGE_ROOT=/opt/sge
    #http://www.softpanorama.org/HPC/Grid_engine/Installation/installation_of_master_host.shtml
    #https://docs.oracle.com/cd/E19787-01/820-3042/cacdhfdi/index.html
    #Make sure host name(master) is not 127.0.0.1
    ./install_qmaster
    source ${SGE_ROOT}/kwiat/common/settings.sh
    ./util/setfileperm.sh $SGE_ROOT
fi

