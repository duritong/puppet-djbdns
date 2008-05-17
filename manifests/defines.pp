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
    $masternameserver = 'dns1.glei.ch',
    $additionalnameservers = 'dns2.glei.ch dns3.glei.ch',
    $mainip = '212.103.72.242',
    $hostmaster = 'hostmaster.glei.ch',
    $serial = '1994200401',
    $mailserverip = '212.103.72.240',
    $mailserver_priority = '0',
    $webserverip = 'present'
){
    # add soa record
    djbdns::entry{"soa.d/000-SOA":
        line => "Z${name}:${masternameserver}.:${hostmaster}.:${serial}:",
    }

    # add nameservers
    djbdns::addnameserver{$name: nameserver => $masternameserver }
    case $additionalnameservers {
        '': { info("no additional nameservers defined") }
        default: {
            $nameservers = gsub(split($additionalnameservers, " "), "(.+)", "&${name}::\\1.:")
            djbdns::addaslist{$nameservers: }
        }
    }

    # mailserver?
    case $mailserverip {
        '': { info("no mailserver ip defined, won't define a mailserver")}
        default: {
            $real_mailip = $mailserverip ? {
                'present' => $mainip,
                default => $mailserverip
            }
            djbdns::addmailserver{$name:
                mailserverip => $real_mailip,
                priority => $mailserver_priority,
            } 
        }
    }

    # main A record
    djbdns::addArecord{$name: ip => $real_ip}

    # webserver? add www A record.
    case $webserverip {
        '': { info("no webserver ip defined, won't define a webserver") }
        default: {
            $real_ip = $webserverip ? {
                'present' => $mainip,
                default => $webserverip
            }

            djbdns::addArecord{"www.${name}": ip => $real_ip}
        } 
    }
}

# quite ugly, but straight forward with for example a lists of nameservers
define djbdns::addaslist($type = 'nameservers' ){
    djbdns::entry{"${type}.d/${order}-${type}-${name}":
        line => $name
    }
}

# define a nameserver
define djbdns::addnameserver(
    $domain = '',
    $nameserver = 'dns1.glei.ch'
){
    $real_domain = $domain ? {
        '' => $name,
        default => $domain
    }
    djbdns::entry{"nameservers.d/${name}-${nameserver}":
        line => "&${real_domain}::${nameserver}.:",
    }
}

define djbdns::addmailserver(
    $domain = '',
    $mailserverip = '212.103.72.240',
    $priority = '0',
    $ttl = '3600'
){
    $real_domain = $domain ? {
        '' => $name,
        default => $domain
    }
    djbdns::entry{"mx-records.d/mailserver-${name}":
        line => "@${real_domain}::mail.${real_domain}.:${priority}:${ttl}::",
    }
    djbdns::addArecord{"mailserver-${name}":
        a_record => 'mail',
        ip => $mailserverip,
        domain => $real_domain,
    }
}

define djbdns::addArecord(
    $ip,
    $domain = '',
    $a_record = '',
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
    djbdns::entry{"a_records.d/a_record-${name}":
        line => "+${real_a_record}:${ip}:${ttl}::${device}",
    }
}

define djbdns::addCname(
    $target,
    $ttl = '3600'
){
    djbdns::entry{"cnames.d/040-c_name-${name}":
        line => "C${name}:${target}:${ttl}
    }
}



define djbdns::managed_file () {
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
        notify => Exec["concat_${dir}"],
        mode => 0600, owner => root, group => 0;
    }
}
