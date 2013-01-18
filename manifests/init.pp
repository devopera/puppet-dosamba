class dosamba (

  # class arguments
  # ---------------
  # setup defaults

  $workgroup = 'WORKGROUP',

  # end of class arguments
  # ----------------------
  # begin class

) {
  # install and configure samba
  class { 'samba::server':
    workgroup            => $workgroup,
    server_string        => "${::hostname} on ${workgroup} workgroup",
    netbios_name         => "${::hostname}",
    interfaces           => [ 'lo', 'eth0' ],
    hosts_allow          => [ '127.', '192.168.', '10.12.', ],
    max_log_size         => 50,
    local_master         => 'no',
    extra_global_options => [
      'follow symlinks = yes',
      'wide links = yes',
      'unix extensions = no',
      'encrypt passwords = yes',
    ],
    shares => {
      'homes' => [
        'comment = Home Directories',
        'browseable = no',
        'writable = yes',
      ],
    },
    selinux_enable_home_dirs => true,
  }->
  
  # then setup firewall rules
  firewall { '00137 NetBIOS Name Service':
    action => 'accept',
    proto  => 'udp',
    dport  => '137',
  }->
  firewall { '00138 NetBIOS Datagram Service':
    action => 'accept',
    proto  => 'udp',
    dport  => '138',
  }->
  firewall { '00139 NetBIOS Session Service':
    action => 'accept',
    proto  => 'tcp',
    dport  => '139',
  }->
  firewall { '00445 Microsoft Directory Service':
    action => 'accept',
    proto  => 'udp',
    dport  => '445',
  }
  
  # also install a samba client for testing
  package { 'samba-client' :
    ensure => present,
  }
}