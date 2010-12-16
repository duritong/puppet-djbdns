class djbdns::debian inherits djbdns::usrbin {
  group{
    'dnslog':
      before => Package['djbdns'],
      gid => 103;
    'tinydns':
      before => Package['djbdns'],
      gid => 104;
  }

  User::Managed['axfrdns']{
    uid => 104,
        gid => 65534,
    manage_group => false,
  }
}
