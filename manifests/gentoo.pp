class djbdns::gentoo inherits djbdns::usrbin {
  group{
    'dnslog':
      before => Package['djbdns'],
      gid => 103;
    'tinydns':
      before => Package['djbdns'],
      gid => 104;
  }

  Package[djbdns]{
    category => 'net-dns',
  }
  User::Managed['axfrdns']{
    gid => 200,
  }
}
