class profile::cluster::mpi(
    Optional[String] $mpi_version = '2.0.2'
){

        #Needs to be configured with sge
        #Could get the source via apt
        #But it's a really old version
        #apt-get source openmpi

		$mpi_source_url = "https://www.open-mpi.org/software/ompi/v2.0/downloads/openmpi-${mpi_version}.tar.bz2"
        $mpi_source = '/tmp/openmpi.tar.bz2'
		wget::fetch {'mpi-download':
			timeout  => 0,
			destination => "${mpi_source}",
			source  => "${mpi_source_url}",
            #sh not bash therefore = not ==
            unless => "test `/usr/local/bin/orte-info | grep 'Open RTE:' | awk '{print \$3}'` = ${mpi_version}"
		}
		->
		exec {'mpi_unpack':
			provider => shell,
            cwd => '/tmp',
			command  => "tar xjf ${mpi_source}",
            unless => "test `/usr/local/bin/orte-info | grep 'Open RTE:' | awk '{print \$3}'` = ${mpi_version}"
		}
		->
		exec {'mpi_configure':
			provider => shell,
            cwd => "/tmp/openmpi-${mpi_version}",
            timeout => 0,
			command  => "./configure --with-sge",
            unless => "test `/usr/local/bin/orte-info | grep 'Open RTE:' | awk '{print \$3}'` = ${mpi_version}"
		}
		->
		exec {'mpi_build':
			provider => shell,
            cwd => "/tmp/openmpi-${mpi_version}",
            timeout => 0,
			command  => "make install",
            unless => "test `/usr/local/bin/orte-info | grep 'Open RTE:' | awk '{print \$3}'` = ${mpi_version}"
		}
		->
		exec {'mpi_setup':
			provider => shell,
            cwd => "/tmp/openmpi-${mpi_version}",
			command  => "ldconfig",
            require => [ Exec['mpi_build'] ]
		}

        package { 'libhdf5-mpi-dev':
            require => [ Exec['mpi_setup'] ]
		}

        package { 'python-mpi4py':
            require => [ Exec['mpi_setup'] ]
		}
}
