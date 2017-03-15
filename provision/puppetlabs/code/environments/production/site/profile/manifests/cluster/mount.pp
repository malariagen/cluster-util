class profile::cluster::mount(
    $users,
    $level1,
    $level2,
    Optional[String] $home_server = 'papa.well.ox.ac.uk',
    Optional[String] $level1_server = 'papa.well.ox.ac.uk',
    Optional[String] $level2_server = 'papa.well.ox.ac.uk',
) {

    $nfs_options = "rw,rsize=32768,wsize=32768,intr,noatime,nfsvers=3,soft,bg,actimeo=0,timeo=600"

    $users.each |String $user| {
        mount { "/home/${user}":
                    device  => "${home_server}:/homes/${user}",
                    fstype  => "nfs",
                    ensure  => "mounted",
                    options => $nfs_options,
                    atboot  => false,
        }
    }

    $level1.each |String $dir| {
        mount { "/kwiat/1/${dir}":
                    device  => "${level1_server}:/kwiat/1/${dir}",
                    fstype  => "nfs",
                    ensure  => "mounted",
                    options => $nfs_options,
                    atboot  => false,
        }
    }
    $level2.each |String $dir| {
        mount { "/kwiat/2/${dir}":
                    device  => "${level2_server}:/kwiat/2/${dir}",
                    fstype  => "nfs",
                    ensure  => "mounted",
                    options => $nfs_options,
                    atboot  => false,
        }
    }
}
