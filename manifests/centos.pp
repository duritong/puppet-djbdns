class djbdns::centos inherits djbdns::base {
    service{'djbdns':
        ensure => running,
        enable => true,
        hasstatus => true,
        require => Package['djbdns'],
    }

    file{'/etc/sysconfig/djbdns.secondaries':
        source => [ "puppet://$server/files/djbdns/sysconfig/${fqdn}/djbdns.secondaries",
                    "puppet://$server/files/djbdns/sysconfig/djbdns.secondaries",
                    "puppet://$server/modules/djbdns/sysconfig/${operatingsystem}/djbdns.secondaries",
                    "puppet://$server/modules/djbdns/sysconfig/djbdns.secondaries" ],
        require => Package['djbdns'],
        owner => root, group => 0, mode => 0644;
    }
}
