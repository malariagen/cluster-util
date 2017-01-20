sudo DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential
if [ ! -x /usr/local/bin/orte-info ]
then
	wget -q https://www.open-mpi.org/software/ompi/v2.0/downloads/openmpi-2.0.1.tar.bz2
	tar xjf openmpi-2.0.1.tar.bz2 
	cd openmpi-2.0.1/
	./configure --with-sge
	make
	sudo make install
	sudo ldconfig
fi
exit 0
