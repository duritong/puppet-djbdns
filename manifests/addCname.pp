define djbdns::addCname(
    $target,
    $ttl = '3600',
    $location = 'ex'
){
    djbdns::entry{"cnames.d/000-cnames-${name}":
        line => "C${name}:${target}:${ttl}::${location}",
    }
}
