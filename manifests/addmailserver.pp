# if you set the mailserverip
# to the default, it will add 
# a A name as well
# if you point it to something
# else, it have to be domain
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
    case $mailserverip {
        '212.103.72.240': {
            djbdns::entry{"mx-records.d/000-mx-records-${name}":
                line => "@${real_domain}::mail.${real_domain}.:${priority}:${ttl}::",
            }
            djbdns::addArecord{"mailserver-${name}":
                a_record => "mail.${real_domain}",
                ip => $mailserverip,
            }
        }
        default: {
            djbdns::entry{"mx-records.d/000-mx-records-${name}":
                line => "@${real_domain}::${mailserverip}.:${priority}:${ttl}::",
            }
        }
    }
}
