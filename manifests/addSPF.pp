define djbdns::addSPF(
    $content = '\046v=spf1\040ip4\072212.103.72.224\05727\040a\040mx\040?all',
    $ttl = '3600'
){
    djbdns::entry{"spf.d/000-spf-${name}":
        line => ":${name}:16:${content}:${ttl}",
    }
}
