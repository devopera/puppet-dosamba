class dosamba::firewall (

  # class arguments
  # ---------------
  # setup defaults

  # end of class arguments
  # ----------------------
  # begin class

) {

  @docommon::fireport { '00137 NetBIOS Name Service':
    protocol => 'udp',
    port     => '137',
  }
  @docommon::fireport { '00138 NetBIOS Datagram Service':
    protocol => 'udp',
    port     => '138',
  }
  @docommon::fireport { '00139 NetBIOS Session Service':
    protocol => 'tcp',
    port     => '139',
  }
  @docommon::fireport { '00445 Microsoft Directory Service':
    protocol => 'udp',
    port     => '445',
  }

}
