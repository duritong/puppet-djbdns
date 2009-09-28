class djbdns::usrbin inherits djbdns::base {
    Exec['tiny_dns_setup']{
        command => "/usr/bin/tinydns-conf tinydns dnslog /var/tinydns $ipaddress",
    }
    Exec['axfr_dns_setup']{
        command => "/usr/bin/axfrdns-conf axfrdns dnslog /var/axfrdns /var/tinydns $ipaddress",
    }
}
