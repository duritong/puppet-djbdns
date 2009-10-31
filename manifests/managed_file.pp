define djbdns::managed_file () {
  include djbdns::modules_dir
  concatenated_file { "/var/lib/puppet/modules/djbdns/$name":
    dir => "/var/lib/puppet/modules/djbdns/${name}.d",
    owner => root, group => 0, mode => 0600;
  }
}
