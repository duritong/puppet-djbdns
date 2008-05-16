# manifests/define.pp
#
# this file is thought to be used to manage domains

define djbdns::headerinfos(
    # set a default external device
    $content = '%ex'
){
    djbdns::entry{"000-header-${name}":
        line => $content,
    }
}

define djbdns::adddomain(
    $timeout = '3600',
    $masternameserver = 'dns1.glei.ch',
    $hostmaster = 'hostnamster.glei.ch',
    $serial = '10455',
    $mailserverip = '212.103.72.240',
    $mailserver_priority = '0',
    $webserverip = '212.103.72.242'
){
    djbdns::entry{"${name}.d/000-SOA":
        line => "Z${name}:${masternameserver}.:${hostnamster}.:${serial}:",
    }
    djbdns::addnameserver{$name: 
        nameserver => $masternameserver,
    }

    djbdns::addmailserver{$name:
        mailserverip => $mailserverip,
        priority => $mailserver_priority,
    } 
}

define djbdns::addnameserver(
    $domain = '',
    $nameserver = 'dns1.glei.ch'
){
    $real_domain = $domain ? {
        '' => $name,
        default => $domain
    }
    djbdns::entry{"${real_domain}.d/010-nameserver-${nameserver}":
        line => "&${real_domain}::${nameserver}.",
    }
}

define djbdns::addmailserver(
    $domain = '',
    $mailserverip = '212.103.72.240',
    $priority = '0'
){
    $real_domain = $domain ? {
        '' => $name,
        default => $domain
    }
    djbdns::entry{"${real_domain}.d/02${priority}-mailserver-${name}":
        line => "@${real_domain}::mail.${real_domain}.:${priority}",
    }
    djbdns::addArecord{$name:
        a_record => 'mail',
        ip => $mailserverip,
        domain => $real_domain,
    }
}

define djbdns::addArecord(
    $a_record,
    $ip,
    $domain = '',
    $ttl = '3600',
    $device = 'ex'
) {
    $real_domain = $domain ? {
        '' => $name,
        default => $domain
    }
    djbdns::entry{"${real_domain}.d/030-a_record-{$name}":
        line => "+${a_record}.{real_domain}:${ip}:${ttl}::${device}",
    }
}



define djbdns::managed_file () {
    $dir = "/var/lib/puppet/modules/djbdns/${name}.d"

    file {"${dir}":
        ensure => directory,
        force => true,
        purge => true,
        recurse => true,
        mode => 0755, owner => root, group => 0;
    }


    concatenated_file { "/var/lib/puppet/modules/djbdns/$name":
        dir => $dir,
        mode => 0600,
    }
}


define djbdns::entry ($line) {
    $target = "/var/lib/puppet/modules/djbdns/${name}"
    $dir = dirname($target)
    file { $target:
        content => "${line}\n",
        mode => 0600, owner => root, group => 0,
        notify => Exec["concat_${dir}"],
    }
}
