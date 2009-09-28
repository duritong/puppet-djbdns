define djbdns::entry ($line) {
    $target = "/var/lib/puppet/modules/djbdns/${name}"
    $dir = dirname($target)
    file { $target:
        content => "${line}\n",
        notify => Exec["concat_${dir}"],
        mode => 0600, owner => root, group => 0;
    }
}
