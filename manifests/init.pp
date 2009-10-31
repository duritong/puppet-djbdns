# modules/djbdns/manifests/init.pp - manage djbdns stuff
# Copyright (C) 2007 admin@immerda.ch
#
# For rpms for redhat, centos etc. you might want to look here:
# http://summersoft.fay.ar.us/pub/qmail/djbdns/
#

class djbdns {
    case $operatingsystem {
        gentoo: { include djbdns::gentoo }
        debian: { include djbdns::debian }
        centos: { include djbdns::centos }
        default: { include djbdns::base }
    }

    if $use_munin {
        include munin::plugins::djbdns
    }

    if $use_shorewall {
      include shorewall::rules::dns
    }
}
