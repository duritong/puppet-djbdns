# manifests/define.pp
#
# this file is thought to be used to manage domains

define djbdns::headerinfos(
    # set a default external location
    $content = '%ex'
){
    djbdns::entry{"00-headers.d/000-header-${name}":
        line => $content,
    }
}

define djbdns::adddomain(
    $timeout = '3600',
    # you can add more than one nameserver by using a list seperated by spaces
    $masternameserver = 'dns1.glei.ch',
    # absent will ignore them, otherweise you can define a list separated by spaces
    $additionalnameservers = 'dns2.glei.ch dns3.glei.ch',
    $mainip = '212.103.72.242',
    $hostmaster = 'hostmaster.glei.ch',
    # if you use zone transfers you should update them 
    # ToDo: this sould be increased automagically ;)
    $serial = '1994200401',
    # absent will ignore it, an ip will be used and present sets the ip to the mainip
    $mailserverip = '212.103.72.240',
    $mailserver_priority = '0',
    # absent will ignore it, an ip will be used and present sets the ip to the mainip
    $webserverip = 'present'
){
    # add soa record
    djbdns::entry{"soa.d/000-soa-${name}":
        line => "Z${name}:${masternameserver}.:${hostmaster}.:${serial}:",
    }

    # add nameservers
    djbdns::addnameserver{$name: nameserver => $masternameserver }
    case $additionalnameservers {
        'absent': { info("no additional nameservers defined") }
        default: {
            $nameservers = gsub(split($additionalnameservers, " "), "(.+)", "&${name}::\\1.:")
            djbdns::addaslist{$nameservers: }
        }
    }

    # mailserver?
    case $mailserverip {
        'absent': { info("no mailserver ip defined, won't define a mailserver")}
        default: {
            $real_mailip = $mailserverip ? {
                'present' => $mainip,
                default => $mailserverip
            }
            djbdns::addmailserver{$name:
                mailserverip => $real_mailip,
                priority => $mailserver_priority,
            } 
            # if we have a mailserver we also define an spf entry
            djbdns::addSPF{$name: }
        }
    }

    # main A record
    djbdns::addArecord{$name: ip => $mainip}

    # webserver? add www A record.
    case $webserverip {
        'absent': { info("no webserver ip defined, won't define a webserver") }
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
    # 999 because lists should go rather to the end
    djbdns::entry{"${type}.d/999-${type}-${name}":
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
    djbdns::entry{"nameservers.d/000-nameservers-${name}-${nameserver}":
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
    djbdns::entry{"mx-records.d/000-mx-records-${name}":
        line => "@${real_domain}::mail.${real_domain}.:${priority}:${ttl}::",
    }
    djbdns::addArecord{"mailserver-${name}":
        a_record => "mail.${real_domain}",
        ip => $mailserverip,
    }
}

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

define djbdns::addCname(
    $target,
    $ttl = '3600'
    $location = 'ex'
){
    djbdns::entry{"cnames.d/000-cnames-${name}":
        line => "C${name}:${target}:${ttl}::${location}",
    }
}

define djbdns::addSPF(
    $content = '\046v=spf1\040ip4\072212.103.72.224\05727\040a\040mx\040?all'
    $ttl = '3600',
){
    djbdns::entry{"spf.d/000-spf-${name}":
        line => ":${name}:16:${content}:${ttl}",
    }
}

define djbdns::addReverse(
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
        line => "=${real_domain}:${ip}:${ttl}::${location}",
    }
}

define djbdns::managed_file () {
    concatenated_file { "/var/lib/puppet/modules/djbdns/$name":
        dir => "/var/lib/puppet/modules/djbdns/${name}.d",
        owner => root, group => 0, mode => 0600;
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
