class djbdns::gentoo inherits djbdns::usrbin {
    Package[djbdns]{
        category => 'net-dns',
    }
    User::Managed['axfrdns']{
        gid => 200,
    }
}
