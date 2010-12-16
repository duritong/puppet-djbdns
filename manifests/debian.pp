class djbdns::debian inherits djbdns::usrbin {
  user{
    'dnslog':
      before => Package['djbdns'],
      gid => 103;
  }

  User::Managed['axfrdns']{
    uid => 104,
        gid => 65534,
    manage_group => false,
  }
}
