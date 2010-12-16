class djbdns::gentoo inherits djbdns::usrbin {
  user{
    'dnslog':
      before => Package['djbdns'],
      gid => 103;
  }

  Package[djbdns]{
    category => 'net-dns',
  }
  User::Managed['axfrdns']{
    gid => 200,
  }
}
