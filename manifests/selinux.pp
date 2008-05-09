# manifests/selinux.pp

class djbdns::selinux {
    case $operatingsystem {
        gentoo: { include djbdns::selinux::gentoo }
        default: { info("No selinux stuff yet defined for your operatingsystem") }
    }
}

class djbdns::selinux::gentoo {
    package{'selinux-djbdns':
        ensure => present,
        category => 'sec-policy',
        require => Package[djbdns],
    }
    selinux::loadmodule {"djbdns": require => Package[selinux-djbdns] }
}

