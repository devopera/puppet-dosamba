#
# requires docommon
#
class dosamba (

  # class arguments
  # ---------------
  # setup defaults

  $user                     = 'web',
  $user_password            = 'admLn**',
  $workgroup                = 'WORKGROUP',
  $security                 = 'user',
  $username_map             = '#',
  $selinux_enable_home_dirs = true,
  $selinux_enable_www_dirs  = false,
  $selinux_enable_all_dirs  = true,
  $printing                 = 'bsd',
  $printcap_name            = '/dev/null',
  $shares = {
    'homes' => [
      'comment = Home Directories',
      'browseable = no',
      'writable = yes',
      'create mask = 0640',
      'directory mask = 0750',
    ],
  },

  # open up firewall ports and monitor
  $firewall                 = true,
  $monitor                  = true,

  # end of class arguments
  # ----------------------
  # begin class

) {

  # open up firewall ports and monitor
  if ($firewall) {
    class { 'dosamba::firewall' : }
  }
  if ($monitor) {
    class { 'dosamba::monitor' :
      user => $user,
      password => $user_password,
      # test share on username
      # @todo parameterise because may not be sharing homes
      share => $user,
      workgroup => $workgroup,
    }
  }

  # if we've got a message of the day, include samba
  @domotd::register { 'Samba(139)' : }
  
  # install and configure samba
  class { 'samba::server':
    workgroup            => $workgroup,
    # temporarily removed two new fields because samba needs a patch downstream
    security             => $security,
    map_to_guest         => 'Bad User',
    server_string        => "${::hostname} on ${workgroup} workgroup",
    netbios_name         => "${::hostname}",
    interfaces           => [ 'lo', 'eth0' ],
    hosts_allow          => [ '127.', '192.168.', '10.12.', ],
    max_log_size         => 50,
    local_master         => 'no',
    extra_global_options => [
      'follow symlinks   = yes',
      'wide links        = yes',
      'unix extensions   = no',
      'encrypt passwords = yes',
      'map archive       = no',
      "username map      = ${username_map}",
      "printing          = ${printing}",
      "printcap name     = ${printcap_name}",
      # 'show add printer wizard = no',
      # 'load printers   = no',
      # 'disable spools = yes',
    ],
    shares => $shares,
    selinux_enable_home_dirs => $selinux_enable_home_dirs,
    selinux_export_all_rw    => $selinux_enable_all_dirs,
  }

  # if we're running SELinux
  if (str2bool($::selinux)) {

    # fix samba module bug; set selboolean default to persistent
    Selboolean { persistent => true }

    # manually give samba SELinux access to www directories
    # note: this gets wiped out by git checkouts
    if ($selinux_enable_www_dirs) {
      exec { 'dosamba-enable-www-dirs' :
        path => '/bin:/usr/bin:/usr/sbin',
        provider => 'shell',
        command => "bash -c \"semanage fcontext -a -t public_content_rw_t '/var/www(/.*)?'; restorecon -R /var/www\"",
        user => 'root',
        require => Class['samba::server'],
      }->
      selboolean { 'allow_smbd_anon_write' :
        value => 'on',
        persistent => 'true',
      }->
      selboolean { 'allow_httpd_anon_write' :
        value => 'on',
        persistent => 'true',
      }
    }
  }
  
  # set password for user
  exec { 'dosamba-set-mainuser-password':
    path => '/bin:/usr/bin',
    provider => 'shell',
    command => "bash -c '(echo \'${user_password}\'; echo \'${user_password}\') | smbpasswd -as ${user}'",
    user => 'root',
    require => Class['samba::server'],
  }
  
  # also install a samba client for testing
  package { 'samba-client' :
    ensure => present,
  }

}
