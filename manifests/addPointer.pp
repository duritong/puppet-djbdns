define djbdns::addPointer(
    $ip,
    $domain = 'absent',
    $ttl = '3600',
    $location = 'ex'
){
    $real_domain = $domain ? {
        'absent' => $name,
        default => $domain
    }
    djbdns::entry{"reverse.d/000-reverse-${name}":
        line => "^${real_domain}:${ip}:${ttl}::${location}",
    }
}
