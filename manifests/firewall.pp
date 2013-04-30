class dosamba::firewall (

  # class arguments
  # ---------------
  # setup defaults

  # end of class arguments
  # ----------------------
  # begin class

) {

  @firewall { '00137 NetBIOS Name Service':
    protocol => 'udp',
    port     => '137',
  }
  @firewall { '00138 NetBIOS Datagram Service':
    protocol => 'udp',
    port     => '138',
  }
  @firewall { '00139 NetBIOS Session Service':
    protocol => 'tcp',
    port     => '139',
  }
  @firewall { '00445 Microsoft Directory Service':
    protocol => 'udp',
    port     => '445',
  }

}
