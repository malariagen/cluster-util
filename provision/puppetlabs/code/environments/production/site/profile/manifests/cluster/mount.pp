class profile::cluster::mount(
) {

    $user = 'iwright'
    profile::cluster::home { 'home':
        user => "${user}"
    }

}
