class djbdns::base {
  #we need daemontools for djbdns
  include daemontools

  package { 'djbdns':
    ensure => present,
  }

  user::managed{ "axfrdns":
    homedir => "/nonexistent",
    managehome => false,
    shell => "/usr/sbin/nologin",
    uid => 105, gid => 105;
  }

  exec { 'tiny_dns_setup':
    command => "/bin/tinydns-conf tinydns dnslog /var/tinydns $ipaddress",
    creates => "/var/tinydns/env/IP",
    require => Package['djbdns'],
  }
  exec { 'axfr_dns_setup':
    command => "/bin/axfrdns-conf axfrdns dnslog /var/axfrdns /var/tinydns $ipaddress",
    creates => "/var/axfrdns/env/IP",
    require => Package['djbdns'],
  }

  # tcp file, must make afterwards
  file { "/var/axfrdns/tcp":
    source => "puppet:///modules/djbdns/axfrdnstcp",
    require => Package['djbdns'],
    owner => tinydns, group => 0, mode => 0644;
  }
  exec { "/usr/bin/make -f /var/axfrdns/Makefile -C /var/axfrdns/":
    subscribe => File["/var/axfrdns/tcp"],
    require => Package['djbdns'],
    refreshonly => true
  }

  daemontools::service{"tinydns":
    source => "/var/tinydns",
    require => Package['djbdns'],
  }
  daemontools::service{"axfrdns":
    source => "/var/axfrdns",
    require => Package['djbdns'],
  }

  file{'djbdns_data_file':
    path => '/var/tinydns/root/data',
    source => [ "puppet:///modules/site-djbdns/${fqdn}/data",
                "puppet:///modules/site-djbdns/${domain}/data",
                "puppet:///modules/site-djbdns/${dns_cluster}/data",
                "puppet:///modules/site-djbdns/data",
                "puppet:///modules/djbdns/data" ],
    require => Package['djbdns'],
    notify => Exec['generate_data_db'],
    owner => root, group => 0, mode => 0644;
  }

  exec{'generate_data_db':
    command => 'make -f /var/tinydns/root/Makefile -C /var/tinydns/root/',
    refreshonly => true,
  }
}
