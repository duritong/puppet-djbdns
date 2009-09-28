# define a nameserver
define djbdns::addnameserver(
    $domain = '',
    $nameserver = 'dns1.glei.ch'
){
    $real_domain = $domain ? {
        '' => $name,
        default => $domain
    }
    djbdns::entry{"nameservers.d/000-nameservers-${name}-${nameserver}":
        line => "&${real_domain}::${nameserver}.:",
    }
}
