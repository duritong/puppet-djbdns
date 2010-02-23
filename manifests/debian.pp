class djbdns::debian inherits djbdns::usrbin {
    User::Managed['axfrdns']{
        uid => 104,
        gid => 65534,
        manage_group => false,
    }
}
