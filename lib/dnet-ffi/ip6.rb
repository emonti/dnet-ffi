module Dnet
  # /*
  #  * IPv6 header
  #  */
  # struct ip6_hdr {
  # 	union {
  # 		struct ip6_hdr_ctl {
  # 			uint32_t	ip6_un1_flow; /* 20 bits of flow ID */
  # 			uint16_t	ip6_un1_plen; /* payload length */
  # 			uint8_t		ip6_un1_nxt;  /* next header */
  # 			uint8_t		ip6_un1_hlim; /* hop limit */
  # 		} ip6_un1;
  # 		uint8_t	ip6_un2_vfc;	/* 4 bits version, top 4 bits class */
  # 	} ip6_ctlun;
  # 	ip6_addr_t	ip6_src;
  # 	ip6_addr_t	ip6_dst;
  # } __attribute__((__packed__));


  # 
  #  Preferred extension header order from RFC 2460, 4.1:
  #
  #  IP_PROTO_IPV6, IP_PROTO_HOPOPTS, IP_PROTO_DSTOPTS, IP_PROTO_ROUTING,
  #  IP_PROTO_FRAGMENT, IP_PROTO_AH, IP_PROTO_ESP, IP_PROTO_DSTOPTS, 
  #  IP_PROTO_*
  #

  # /*
  #  * Routing header data (IP_PROTO_ROUTING)
  #  */
  # struct ip6_ext_data_routing {
  # 	uint8_t  type;			/* routing type */
  # 	uint8_t  segleft;		/* segments left */
  # 	/* followed by routing type specific data */
  # } __attribute__((__packed__));


  # struct ip6_ext_data_routing0 {
  # 	uint8_t  type;			/* always zero */
  # 	uint8_t  segleft;		/* segments left */
  # 	uint8_t  reserved;		/* reserved field */
  # 	uint8_t  slmap[3];		/* strict/loose bit map */
  # 	ip6_addr_t  addr[1];		/* up to 23 addresses */
  # } __attribute__((__packed__));


  # /*
  #  * Fragment header data (IP_PROTO_FRAGMENT)
  #  */
  # struct ip6_ext_data_fragment {
  # 	uint16_t  offlg;		/* offset, reserved, and flag */
  # 	uint32_t  ident;		/* identification */
  # } __attribute__((__packed__));
  # 
  #     void ip6_checksum(void *buf, size_t len);

  attach_function :ip6_checksum, [:pointer, :size_t], :void

end
