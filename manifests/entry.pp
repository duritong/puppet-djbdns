define djbdns::entry ($line) {
    include djbdns::modules_dir
    $target = "/var/lib/puppet/modules/djbdns/${name}"
    $dir = dirname($target)
    file { $target:
        content => "${line}\n",
        notify => Exec["concat_${dir}"],
        mode => 0600, owner => root, group => 0;
    }
}
