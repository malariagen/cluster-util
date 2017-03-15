
define profile::cluster::home(
    String $user,
) {

    $home_server = lookup('profile::cluster::home::home_server', { default_value => 'papa.well.ox.ac.uk'} )
    mount { "/home/${user}":
            device  => "${home_server}:/homes/${user}",
            fstype  => "nfs",
            ensure  => "mounted",
            options => "rw,rsize=32768,wsize=32768,intr,noatime,nfsvers=3",
            atboot  => false,
    }
}
