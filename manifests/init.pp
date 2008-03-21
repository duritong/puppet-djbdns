# modules/djbdns/manifests/init.pp - manage djbdns stuff
# Copyright (C) 2007 admin@immerda.ch
#

# modules_dir { "djbdns": }

class djbdns {
    package { 'djbdns':
        ensure => present,
        category => $operatingsystem ? {
            gentoo => 'net-dns',
            default => '',
        }
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
    
    case $operatingsystem {
        gentoo:{
            selinux::loadmodule {"djbdns": location => "/usr/share/selinux/strict/djbdns.pp" }
            selinux::loadmodule {"daemontools": location => "/usr/share/selinux/strict/daemontools.pp" }
        }
    }

    exec { "/usr/bin/tinydns-conf tinydns dnslog /var/tinydns $ipaddress":
        creates => "/var/tinydns/env/IP"
    }
    exec { "/usr/bin/axfrdns-conf axfrdns dnslog /var/axfrdns /var/tinydns $ipaddress":
        creates => "/var/axfrdns/env/IP"
    }

    # relabel on gentoo, just the first time
    case $operatingsystem {
        gentoo:{
            # if selinux ... ????
            exec { "/usr/sbin/rlpkg daemontools djbdns":
                path => "/usr/bin:/usr/sbin:/bin",
                unless => "/usr/bin/ls -laZ /var/tinydns/root/add-alias | /bin/grep djbdns_tinydns_conf_t 2>/dev/null"
            }
        }
    }

# tcp file, must make afterwards
    file { "/var/axfrdns/tcp":
        ensure => "present",
        source => "puppet://$servername/djbdns/axfrdnstcp",
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

    include munin::plugins::djbdns
}

