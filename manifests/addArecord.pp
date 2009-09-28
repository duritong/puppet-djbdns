define djbdns::addArecord(
    $ip,
    $a_record = 'absent',
    $ttl = '3600',
    $location = 'ex'
) {
    case $a_record {
        'absent': { $real_a_record = $name }
        default: { $real_a_record = $a_record }
    }
    djbdns::entry{"a_records.d/000-a_records-${name}":
        line => "+${real_a_record}:${ip}:${ttl}::${location}",
    }
}
