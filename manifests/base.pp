class djbdns::base {
    #we need daemontools for djbdns
    include daemontools

    package { 'djbdns':
        ensure => present,
    }
    
    user::managed{ "axfrdns":
        homedir => "/nonexistent",
        managehome => false,
        shell => "/usr/sbin/nologin",
        uid => 105, gid => 105;
    }

    exec { 'tiny_dns_setup':
        command => "/bin/tinydns-conf tinydns dnslog /var/tinydns $ipaddress",
        creates => "/var/tinydns/env/IP",
        require => Package['djbdns'],
    }
    exec { 'axfr_dns_setup':
        command => "/bin/axfrdns-conf axfrdns dnslog /var/axfrdns /var/tinydns $ipaddress",
        creates => "/var/axfrdns/env/IP",
        require => Package['djbdns'],
    }

    # tcp file, must make afterwards
    file { "/var/axfrdns/tcp":
        source => "puppet://$server/modules/djbdns/axfrdnstcp",
        require => Package['djbdns'],
        owner => tinydns, group => 0, mode => 0644;
    }
    exec { "/usr/bin/make -f /var/axfrdns/Makefile -C /var/axfrdns/":
        subscribe => File["/var/axfrdns/tcp"],
        require => Package['djbdns'],
        refreshonly => true
    }

    daemontools::service{"tinydns":
        source => "/var/tinydns",
        require => Package['djbdns'],
    }
    daemontools::service{"axfrdns":
        source => "/var/axfrdns",
        require => Package['djbdns'],
    }

    file { "/var/lib/puppet/modules/djbdns":
        ensure => directory,
        force => true,
        mode => 0755, owner => root, group => 0;
    }

#    this would be the new style which currently doesn't work
#    djbdns::managed_file{[ "00-headers", "soa", "nameservers", "mx-records", "a_records", "txt_records", "cnames", "spf", "reverse"]: }
#
#
#    exec{'copy_data':
#        command => 'cat `find /var/lib/puppet/modules/djbdns/ -maxdepth 1 -type f | sort -n` > /var/tinydns/root/data',
#        refreshonly => true,
#        notify => Exec['generate_data_db'],
#        require => File["/var/lib/puppet/modules/djbdns"],
#        subscribe => [
#            Exec["concat_/var/lib/puppet/modules/djbdns/00-headers"],
#            Exec["concat_/var/lib/puppet/modules/djbdns/soa"],
#            Exec["concat_/var/lib/puppet/modules/djbdns/nameservers"],
#            Exec["concat_/var/lib/puppet/modules/djbdns/mx-records"],
#            Exec["concat_/var/lib/puppet/modules/djbdns/a_records"],
#            Exec["concat_/var/lib/puppet/modules/djbdns/txt_records"],
#            Exec["concat_/var/lib/puppet/modules/djbdns/spf"],
#            Exec["concat_/var/lib/puppet/modules/djbdns/reverse"],
#            Exec["concat_/var/lib/puppet/modules/djbdns/cnames"]
#        ],
#    }

    # currently simply deploying the data file
    file{'djbdns_data_file':
        path => '/var/tinydns/root/data',
        source => [ "puppet://$server/modules/site-djbdns/${fqdn}/data",
                    "puppet://$server/modules/site-djbdns/${domain}/data",
                    "puppet://$server/modules/site-djbdns/data",
                    "puppet://$server/modules/djbdns/data" ],
        notify => Exec['generate_data_db'],
        owner => root, group => 0, mode => 0644;
    }

    exec{'generate_data_db':
        command => 'make -f /var/tinydns/root/Makefile -C /var/tinydns/root/',
        refreshonly => true,
#        require => File["/var/lib/puppet/modules/djbdns"],
    }
}
