class djbdns::centos inherits djbdns::base {
    service{'djbdns':
        ensure => running,
        enable => true,
        hasstatus => true,
        require => Package['djbdns'],
    }
}
