# quite ugly, but straight forward with for example a lists of nameservers
define djbdns::addaslist($type = 'nameservers' ){
    # 999 because lists should go rather to the end
    djbdns::entry{"${type}.d/999-${type}-${name}":
        line => $name
    }
}
