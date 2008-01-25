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

    exec { "/usr/bin/tinydns-conf tinydns dnslog /var/tinydns $ipaddress":
        creates => "/var/tinydns/env/IP"
    }

}

