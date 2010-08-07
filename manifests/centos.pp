class djbdns::centos inherits djbdns::base {
    service{'djbdns':
        ensure => running,
        enable => true,
        hasstatus => true,
        require => Package['djbdns'],
    }

    file{'/etc/sysconfig/djbdns.secondaries':
        source => [ "puppet:///modules/site-djbdns/sysconfig/${fqdn}/djbdns.secondaries",
                    "puppet:///modules/site-djbdns/sysconfig/djbdns.secondaries",
                    "puppet:///modules/djbdns/sysconfig/${operatingsystem}/djbdns.secondaries",
                    "puppet:///modules/djbdns/sysconfig/djbdns.secondaries" ],
        require => Package['djbdns'],
        owner => root, group => 0, mode => 0644;
    }
}
