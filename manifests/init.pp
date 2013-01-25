#
# requires docommon
#
class dosamba (

  # class arguments
  # ---------------
  # setup defaults

  $user = 'web',
  $user_password = 'admLn**',
  $workgroup = 'WORKGROUP',

  # end of class arguments
  # ----------------------
  # begin class

) {
  # fix samba module bug; set selboolean default to persistent
  Selboolean { persistent => true }
  
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
  
  # set password for user
  exec { 'dosamba-set-mainuser-password':
    path => '/bin:/usr/bin',
    provider => 'shell',
    command => "bash -c '(echo \'${user_password}\'; echo \'${user_password}\') | smbpasswd -as ${user}'",
    user => 'root',
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
    notify  => Exec['persist-firewall'],
    before  => Class['docommon::firewall::post'],
    require => Class['docommon::firewall::pre'],
  }
  
  # also install a samba client for testing
  package { 'samba-client' :
    ensure => present,
  }
}
