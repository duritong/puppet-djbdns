# modules/djbdns/manifests/init.pp - manage djbdns stuff
# Copyright (C) 2007 admin@immerda.ch
#

modules_dir { "djbdns": }

include "defines.pp"

class djbdns {
    case $operatingsystem {
        gentoo: { include djbdns::gentoo }
        default: { include djbdns::base }
    }

    if $selinux {
        include djbdns::selinux
    }

    file { "/var/lib/puppet/modules/djbdns":
        ensure => directory,
        force => true,
        mode => 0755, owner => root, group => 0;
    }
}

class djbdns::base {
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

    # this is starting the dns!
    # ln -s /var/axfrdns /service
    file { "/service/tinydns":
        ensure => "/var/tinydns"
    }
    file { "/service/axfrdns":
        ensure => "/var/axfrdns"
    }

    file {
        "/var/tinydns/root/data":
        ensure => file, owner => tinydns, group => 0, mode => 640,
        source => [ "puppet://$server/files/djbdns/immerda/data", 
                    "puppet://$server/files/djbdns/data",
                    "puppet://$server/djbdns/data" ],
        notify => Exec[generate_data_db],
    }

    exec{'generate_data_db':
        command => 'make -f /var/tinydns/root/Makefile -C /var/tinydns/root/',
        refreshonly => true,
        require => File["/var/tinydns/root/data"],
    }

    case $selinux {
        true: { include djbdns::selinux }
    }

    include munin::plugins::djbdns
}

class djbdns::gentoo inherits djbdns::base {
    Package[djbdns]{
        category => 'net-dns',
    }
}

class djbdns::selinux {
    selinux::loadmodule {"djbdns": location => "/usr/share/selinux/strict/djbdns.pp" }
    selinux::loadmodule {"daemontools": location => "/usr/share/selinux/strict/daemontools.pp" }

    exec { "/usr/sbin/rlpkg daemontools djbdns":
        unless => "/usr/bin/ls -laZ /var/tinydns/root/add-alias | /bin/grep djbdns_tinydns_conf_t 2>/dev/null"
    }
}

