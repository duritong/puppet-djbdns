# modules/djbdns/manifests/init.pp - manage djbdns stuff
# Copyright (C) 2007 admin@immerda.ch
#
# For rpms for redhat, centos etc. you might want to look here:
# http://summersoft.fay.ar.us/pub/qmail/djbdns/
#

modules_dir { "djbdns": }

import "defines.pp"

class djbdns {
    case $operatingsystem {
        gentoo: { include djbdns::gentoo }
        centos: { include djbdns::centos }
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
        gid => 105,
        home => "/nonexistent",
        shell => "/usr/sbin/nologin",
        uid => 105,
    }

    exec { 'tiny_dns_setup':
        command => "/bin/tinydns-conf tinydns dnslog /var/tinydns $ipaddress",
        creates => "/var/tinydns/env/IP"
    }
    exec { 'axfr_dns_setup':
        command => "/bin/axfrdns-conf axfrdns dnslog /var/axfrdns /var/tinydns $ipaddress",
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
    file{'/var/tinydns/root/data':
        source => [ "puppet://$server/files/djbdns/${fqdn}/data",
                    "puppet://$server/files/djbdns/${domain}/data",
                    "puppet://$server/files/djbdns/data",
                    "puppet://$server/djbdns/data" ],
        notify => Exec['generate_data_db'],
        owner => root, group => 0, mode => 0644;
    }

    exec{'generate_data_db':
        command => 'make -f /var/tinydns/root/Makefile -C /var/tinydns/root/',
        refreshonly => true,
#        require => File["/var/lib/puppet/modules/djbdns"],
    }
}

class djbdns::centos inherits djbdns::base {
    service{'djbdns':
        ensure => running,
        enable => true,
        hasstatus => true,
        require => Package['djbdns'],
    }
}

class djbdns::gentoo inherits djbdns::base {
    Package[djbdns]{
        category => 'net-dns',
    }

    Exec['tiny_dns_setup']{
        command => "/usr/bin/tinydns-conf tinydns dnslog /var/tinydns $ipaddress",
    }
    Exec['axfr_dns_setup']{
        command => "/usr/bin/axfrdns-conf axfrdns dnslog /var/axfrdns /var/tinydns $ipaddress",
    }

    User['axfrs']{
        gid => 200,
    }
}

