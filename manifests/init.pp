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
        },
    }

    
    
}

