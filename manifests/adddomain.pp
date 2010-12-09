# masternameserver: you can add more than one nameserver by using a list seperated by spaces
# additionalnameservers: absent will ignore them, otherweise you can define a list separated by spaces
# serial: if you use zone transfers you should update them 
#         ToDo: this sould be increased automagically ;)
# mailserverip: absent will ignore it, an ip will be used and present sets the ip to the mainip
# webserverip: absent will ignore it, an ip will be used and present sets the ip to the mainip
# location: per default we don't need to define a location
define djbdns::adddomain(
    $timeout = '3600',
    $masternameserver = 'dns1.glei.ch',
    $additionalnameservers = 'dns2.glei.ch dns3.glei.ch',
    $mainip = '212.103.72.242',
    $hostmaster = 'hostmaster.glei.ch',
    $serial = '1994200401',
    $mailserverip = '212.103.72.240',
    $mailserver_priority = '0',
    $webserverip = 'present',
    $location = ''
){
    # add soa record
    djbdns::entry{"soa.d/000-soa-${name}":
        line => "Z${name}:${masternameserver}.:${hostmaster}.:${serial}:::::::${location}",
    }

    # add nameservers
    djbdns::addnameserver{$name: nameserver => $masternameserver }
    case $additionalnameservers {
        'absent': { info("no additional nameservers defined") }
        default: {
            $nameservers = regsubst(split($additionalnameservers, " "), "(.+)", "&${name}::\\1.:")
            djbdns::addaslist{$nameservers: }
        }
    }

    # mailserver?
    case $mailserverip {
        'absent': { info("no mailserver ip defined for ${name}, won't define a mailserver")}
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
    case $mainip {
        absent: { info("no mainip define for ${name}, won't define an a record for it") }
        default: {
            djbdns::addArecord{$name: ip => $mainip}
        }
    }

    # webserver? add www A record.
    case $webserverip {
        'absent': { info("no webserver ip defined for ${name}, won't define a webserver") }
        default: {
            $real_ip = $webserverip ? {
                'present' => $mainip,
                default => $webserverip
            }

            djbdns::addArecord{"www.${name}": ip => $real_ip}
        }
    }
}
