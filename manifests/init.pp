# modules/djbdns/manifests/init.pp - manage djbdns stuff
# Copyright (C) 2007 admin@immerda.ch
#

modules_dir { "djbdns": }

import "defines.pp"

class djbdns {
    case $operatingsystem {
        gentoo: { include djbdns::gentoo }
        default: { include djbdns::base }
    }

    if $selinux {
        include djbdns::selinux
    }

    if $use_munin {
        include munin::plugins::djbdns
    }

}

class djbdns::base {
    #we need daemontools for djbdns
    include daemontools

    package { 'djbdns':
        ensure => present,
    }
    
    user { "axfrdns":
        allowdupe => false,
        comment => "tinydnstcp",
        ensure => present,
        gid => 200,
        home => "/nonexistent",
        shell => "/usr/sbin/nologin",
        uid => 105,
    }
    
    exec { "/usr/bin/tinydns-conf tinydns dnslog /var/tinydns $ipaddress":
        creates => "/var/tinydns/env/IP"
    }
    exec { "/usr/bin/axfrdns-conf axfrdns dnslog /var/axfrdns /var/tinydns $ipaddress":
        creates => "/var/axfrdns/env/IP"
    }

    # tcp file, must make afterwards
    file { "/var/axfrdns/tcp":
        ensure => "present",
        source => "puppet://$server/djbdns/axfrdnstcp",
        owner => tinydns, 
        group => 0,
    }
    exec { "/usr/bin/make -f /var/axfrdns/Makefile -C /var/axfrdns/":
        subscribe => File["/var/axfrdns/tcp"],
        refreshonly => true
    }

    daemontools::service{"tinydns":
        source => "/var/tinydns"
    }
    daemontools::service{"axfrdns":
        source => "/var/axfrdns"
    }

    file { "/var/lib/puppet/modules/djbdns":
        ensure => directory,
        force => true,
        mode => 0755, owner => root, group => 0;
    }

    exec{'copy_data':
        command => 'cat `find /var/lib/puppet/modules/djbdns/ -maxdepth 1 -type f` > /var/tinydns/root/data',
        refreshonly => true,
        notify => Exec['generate_data_db'],
        require => File["/var/lib/puppet/modules/djbdns"],
    }

    exec{'generate_data_db':
        command => 'make -f /var/tinydns/root/Makefile -C /var/tinydns/root/',
        refreshonly => true,
        require => File["/var/lib/puppet/modules/djbdns"],
    }
}

class djbdns::gentoo inherits djbdns::base {
    Package[djbdns]{
        category => 'net-dns',
    }
}

