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
    # you can add more than one nameserver by using a list seperated by spaces
    $nameserver = 'dns1.glei.ch dns2.glei.ch dns3.glei.ch',
    $mainip = '212.103.72.242',
    $hostmaster = 'hostmaster.glei.ch',
    $serial = '1994200401',
    $mailserverip = '212.103.72.240',
    $mailserver_priority = '0',
    $webserverip = 'present'
){
    djbdns::managed_file{"$name": }

    djbdns::entry{"${name}.d/000-SOA":
        line => "Z${name}:${masternameserver}.:${hostmaster}.:${serial}:",
    }
    $nameservers = gsub(split($nameserver, " "), "(.+)", "&${name}::\\1.")
    djbdns::addnameserversaslist{$nameservers: }

    case $mailserverip {
        '': { info("no mailserver ip defined, won't define a mailserver")}
        default: {
            djbdns::addmailserver{$name:
                mailserverip => $mailserverip,
                priority => $mailserver_priority,
            } 
        }
    }

    djbdns::addArecord{$name: ip => $real_ip }
    case $webserverip {
        '': { info("no webserver ip defined, won't define a webserver") }
        default: {
            $real_ip = $webserverip ? {
                'present' => $mainip,
                default => $webserverip
            }

            djbdns::addArecord{"www.${name}": ip => $real_ip }
        } 
    }
}

define djbdns::addnameserversaslist($domain){
    djbdns::entry{"${domain}.d/010-nameserver-${name}":
        line => $name
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
    $ip,
    $a_record = '',
    $domain = '',
    $ttl = '3600',
    $device = 'ex'
) {
    $real_domain = $domain ? {
        '' => $name,
        default => $domain
    }

    $real_a_record = $a_record ? {
        '' => $name,
        default => "${a_record}.${real_domain}"
    }
    djbdns::entry{"${real_domain}.d/030-a_record-{$name}":
        line => "+${real_a_record}:${ip}:${ttl}::${device}",
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
