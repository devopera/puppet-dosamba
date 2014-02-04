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

  # check that samba is running as a service
  @nagios::service { "int:process_smbd-dosamba-${::fqdn}":
    check_command => "check_nrpe_procs_smbd",
  }

  # check that the samba share is working
  @nagios::service { "smb:${port}-dosamba-${::fqdn}":
    check_command => "check_disk_smb!${::hostname}!${share}!${workgroup}!${::ipaddress}!${user}!${password}",
  }

}
