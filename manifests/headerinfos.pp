# content: set a default external location
define djbdns::headerinfos(
    $content = '%ex'
){
    djbdns::entry{"00-headers.d/000-header-${name}":
        line => $content,
    }
}
