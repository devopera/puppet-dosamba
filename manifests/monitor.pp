class dosamba::monitor (

  # class arguments
  # ---------------
  # setup defaults
  
  $user = 'web',
  $password = 'admLn**',
  $share = $user,
  $workgroup = 'WORKGROUP',
  $port = 139,
  
  # end of class arguments
  # ----------------------
  # begin class

) {

  # check that the samba share is working
  @nagios::service { "smb:${port}-dosamba-${::hostname}":
    check_command => "check_disk_smb!${::hostname}!${share}!${workgroup}!${::ipaddress}!${user}!${password}",
  }

}
