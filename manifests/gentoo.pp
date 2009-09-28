class djbdns::gentoo inherits djbdns::usrbin {
    Package[djbdns]{
        category => 'net-dns',
    }
    User['axfrdns']{
        gid => 200,
    }
}
