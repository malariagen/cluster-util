class profile::cluster::packages(
    $analysis,
	Optional[String] $rstudio_server_url = undef,
) {

	Apt::Ppa <| |> -> Package <| |>
	Apt::Key<| |> -> Package<| |>
	Class['apt::update'] -> Package <| provider == 'apt' |>

    $analysis.each | $pkg | {

        
        if $pkg[provider] {
            $provider = $pkg[provider]
        } else {
            $provider = 'apt'
        }

        if $pkg[package] {
            $package = $pkg[package]
        } else {
            $package = $pkg[name]
        }

        if $pkg[install_options] {
            package { "${pkg['name']}":
                name => $package,
                install_options => "${pkg['install_options']}",
                provider => "${provider}",
            }
        } else {
            package { "${pkg['name']}":
                name => $package,
                provider => "${provider}"
            }
        }
    }

	if $rstudio_server_url {
		$rstudioserver = '/tmp/rstudio-server.deb'
		wget::fetch {'rstudio-server-download':
			require  => Package['r-base'],
			timeout  => 0,
			destination => "${rstudioserver}",
			source  => "${rstudio_server_url}",
		}
		->
		exec {'rstudio-server-install':
			provider => shell,
			command  => "gdebi -n ${rstudioserver}",
			require  => Package['gdebi'],
		}
	}
}
