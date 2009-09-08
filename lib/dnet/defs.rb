module Dnet
  DNET_DEFS = true

  ######################################################################
  ### include/dnet/addr.h
  ######################################################################

  ADDR_TYPE_NONE  = 0  # No address set
  ADDR_TYPE_ETH   = 1  # Ethernet
  ADDR_TYPE_IP    = 2  # Internet Protocol v4
  ADDR_TYPE_IP6   = 3  # Internet Protocol v6


  ######################################################################
  ### include/dnet/arp.h
  ######################################################################

  ARP_HDR_LEN     = 8        # base ARP header length
  ARP_ETHIP_LEN   = 20      # base ARP message length
  ARP_HRD_ETH     = 0x0001  # ethernet hardware
  ARP_HRD_IEEE802 = 0x0006  # IEEE 802 hardware
  ARP_PRO_IP      = 0x0800  # IP protocol


  ######################################################################
  ### include/dnet/eth.h
  ######################################################################

  ETH_ADDR_LEN   = 6
  ETH_ADDR_BITS  = 48
  ETH_TYPE_LEN   = 2
  ETH_CRC_LEN    = 4
  ETH_HDR_LEN    = 14
  ETH_LEN_MIN    = 64     # minimum frame length with CRC
  ETH_LEN_MAX    = 1518   # maximum frame length with CRC

  ETH_TYPE_PUP        = 0x0200  # PUP protocol
  ETH_TYPE_IP         = 0x0800  # IP protocol
  ETH_TYPE_ARP        = 0x0806  # address resolution protocol
  ETH_TYPE_REVARP     = 0x8035  # reverse addr resolution protocol
  ETH_TYPE_8021Q      = 0x8100  # IEEE 802.1Q VLAN tagging
  ETH_TYPE_IPV6       = 0x86DD  # IPv6 protocol
  ETH_TYPE_MPLS       = 0x8847  # MPLS
  ETH_TYPE_MPLS_MCAST = 0x8848  # MPLS Multicast
  ETH_TYPE_PPPOEDISC  = 0x8863  # PPP Over Ethernet Discovery Stage
  ETH_TYPE_PPPOE      = 0x8864  # PPP Over Ethernet Session Stage
  ETH_TYPE_LOOPBACK   = 0x9000  # used to test interfaces
  ETH_ADDR_BROADCAST = "\xff\xff\xff\xff\xff\xff"

  # ETH_IS_MULTICAST(ea)  (*(ea) & 0x01) # is address mcast/bcast? XXX implement


  ######################################################################
  ### include/dnet/fw.h
  ######################################################################

  FW_OP_ALLOW = 1
  FW_OP_BLOCK = 2
  FW_DIR_IN   = 1
  FW_DIR_OUT  = 2


  ######################################################################
  ### include/dnet/icmp.h
  ######################################################################

  ICMP_HDR_LEN    = 4  # base ICMP header length
  ICMP_LEN_MIN    = 8  # minimum ICMP message size, with header

  ICMP_TRACEROUTE       = 30 # traceroute
  ICMP_DATACONVERR      = 31 # data conversion error
  ICMP_MOBILE_REDIRECT  = 32 # mobile host redirect
  ICMP_IPV6_WHEREAREYOU = 33 # IPv6 where-are-you
  ICMP_IPV6_IAMHERE     = 34 # IPv6 i-am-here
  ICMP_MOBILE_REG       = 35 # mobile registration req
  ICMP_MOBILE_REGREPLY  = 36 # mobile registration reply
  ICMP_DNS              = 37 # domain name request
  ICMP_DNSREPLY         = 38 # domain name reply
  ICMP_SKIP             = 39 # SKIP
  ICMP_PHOTURIS         = 40 # Photuris

  ICMP_RTR_PREF_NODEFAULT =  0x80000000  # do not use as default gw

  ######################################################################
  ### include/dnet/intf.h
  ######################################################################

  INTF_NAME_LEN  = 16

  INTF_TYPE_OTHER     = 1  # other
  INTF_TYPE_ETH       = 6  # Ethernet
  INTF_TYPE_TOKENRING = 9  # Token Ring
  INTF_TYPE_FDDI      = 15 # FDDI
  INTF_TYPE_PPP       = 23 # Point-to-Point Protocol
  INTF_TYPE_LOOPBACK  = 24 # software loopback
  INTF_TYPE_SLIP      = 28 # Serial Line Interface Protocol
  INTF_TYPE_TUN       = 53 # proprietary virtual/internal

  INTF_FLAG_UP          = 0x01  # enable interface
  INTF_FLAG_LOOPBACK    = 0x02  # is a loopback net (r/o)
  INTF_FLAG_POINTOPOINT = 0x04  # point-to-point link (r/o)
  INTF_FLAG_NOARP       = 0x08  # disable ARP
  INTF_FLAG_BROADCAST   = 0x10  # supports broadcast (r/o)
  INTF_FLAG_MULTICAST   = 0x20  # supports multicast (r/o)


  ######################################################################
  ### include/dnet/ip.h
  ######################################################################

  IP_ADDR_LEN     = 4    # IP address length
  IP_ADDR_BITS    = 32   # IP address bits
  IP_HDR_LEN      = 20   # base IP header length
  IP_OPT_LEN      = 2  # base IP option length
  IP_OPT_LEN_MAX  = 40
  IP_HDR_LEN_MAX  = (IP_HDR_LEN + IP_OPT_LEN_MAX)
  IP_LEN_MAX      = 65535
  IP_LEN_MIN      = IP_HDR_LEN

  IP_TOS_DEFAULT              = 0x00    # default
  IP_TOS_LOWDELAY             = 0x10    # low delay
  IP_TOS_THROUGHPUT           = 0x08    # high throughput
  IP_TOS_RELIABILITY          = 0x04    # high reliability
  IP_TOS_LOWCOST              = 0x02    # low monetary cost - XXX
  IP_TOS_ECT                  = 0x02    # ECN-capable transport
  IP_TOS_CE                   = 0x01    # congestion experienced
  IP_TOS_PREC_ROUTINE         = 0x00
  IP_TOS_PREC_PRIORITY        = 0x20
  IP_TOS_PREC_IMMEDIATE       = 0x40
  IP_TOS_PREC_FLASH           = 0x60
  IP_TOS_PREC_FLASHOVERRIDE   = 0x80
  IP_TOS_PREC_CRITIC_ECP      = 0xa0
  IP_TOS_PREC_INTERNETCONTROL = 0xc0
  IP_TOS_PREC_NETCONTROL      = 0xe0

  IP_RF                       = 0x8000 # reserved
  IP_DF                       = 0x4000 # don't fragment
  IP_MF                       = 0x2000 # more fragments (not last frag)
  IP_OFFMASK                  = 0x1fff # mask for fragment offset

  IP_TTL_DEFAULT = 64     # default ttl, RFC 1122, RFC 1340
  IP_TTL_MAX     = 255    # maximum ttl


  # Protocols (ip_p) - http://www.iana.org/assignments/protocol-numbers

  IP_PROTO_IP         = 0            # dummy for IP
  IP_PROTO_ICMP       = 1            # ICMP
  IP_PROTO_IGMP       = 2            # IGMP
  IP_PROTO_GGP        = 3            # gateway-gateway protocol
  IP_PROTO_IPIP       = 4            # IP in IP
  IP_PROTO_ST         = 5            # ST datagram mode
  IP_PROTO_TCP        = 6            # TCP
  IP_PROTO_CBT        = 7            # CBT
  IP_PROTO_EGP        = 8            # exterior gateway protocol
  IP_PROTO_IGP        = 9            # interior gateway protocol
  IP_PROTO_BBNRCC     = 10           # BBN RCC monitoring
  IP_PROTO_NVP        = 11           # Network Voice Protocol
  IP_PROTO_PUP        = 12           # PARC universal packet
  IP_PROTO_ARGUS      = 13           # ARGUS
  IP_PROTO_EMCON      = 14           # EMCON
  IP_PROTO_XNET       = 15           # Cross Net Debugger
  IP_PROTO_CHAOS      = 16           # Chaos
  IP_PROTO_UDP        = 17           # UDP
  IP_PROTO_MUX        = 18           # multiplexing
  IP_PROTO_DCNMEAS    = 19           # DCN measurement
  IP_PROTO_HMP        = 20           # Host Monitoring Protocol
  IP_PROTO_PRM        = 21           # Packet Radio Measurement
  IP_PROTO_IDP        = 22           # Xerox NS IDP
  IP_PROTO_TRUNK1     = 23           # Trunk-1
  IP_PROTO_TRUNK2     = 24           # Trunk-2
  IP_PROTO_LEAF1      = 25           # Leaf-1
  IP_PROTO_LEAF2      = 26           # Leaf-2
  IP_PROTO_RDP        = 27           # "Reliable Datagram" proto
  IP_PROTO_IRTP       = 28           # Inet Reliable Transaction
  IP_PROTO_TP         = 29           # ISO TP class 4
  IP_PROTO_NETBLT     = 30           # Bulk Data Transfer
  IP_PROTO_MFPNSP     = 31           # MFE Network Services
  IP_PROTO_MERITINP   = 32           # Merit Internodal Protocol
  IP_PROTO_SEP        = 33           # Sequential Exchange proto
  IP_PROTO_3PC        = 34           # Third Party Connect proto
  IP_PROTO_IDPR       = 35           # Interdomain Policy Route
  IP_PROTO_XTP        = 36           # Xpress Transfer Protocol
  IP_PROTO_DDP        = 37           # Datagram Delivery Proto
  IP_PROTO_CMTP       = 38           # IDPR Ctrl Message Trans
  IP_PROTO_TPPP       = 39           # TP++ Transport Protocol
  IP_PROTO_IL         = 40           # IL Transport Protocol
  IP_PROTO_IPV6       = 41           # IPv6
  IP_PROTO_SDRP       = 42           # Source Demand Routing
  IP_PROTO_ROUTING    = 43           # IPv6 routing header
  IP_PROTO_FRAGMENT   = 44           # IPv6 fragmentation header
  IP_PROTO_RSVP       = 46           # Reservation protocol
  IP_PROTO_GRE        = 47           # General Routing Encap
  IP_PROTO_MHRP       = 48           # Mobile Host Routing
  IP_PROTO_ENA        = 49           # ENA
  IP_PROTO_ESP        = 50           # Encap Security Payload
  IP_PROTO_AH         = 51           # Authentication Header
  IP_PROTO_INLSP      = 52           # Integated Net Layer Sec
  IP_PROTO_SWIPE      = 53           # SWIPE
  IP_PROTO_NARP       = 54           # NBMA Address Resolution
  IP_PROTO_MOBILE     = 55           # Mobile IP, RFC 2004
  IP_PROTO_TLSP       = 56           # Transport Layer Security
  IP_PROTO_SKIP       = 57           # SKIP
  IP_PROTO_ICMPV6     = 58           # ICMP for IPv6
  IP_PROTO_NONE       = 59           # IPv6 no next header
  IP_PROTO_DSTOPTS    = 60           # IPv6 destination options
  IP_PROTO_ANYHOST    = 61           # any host internal proto
  IP_PROTO_CFTP       = 62           # CFTP
  IP_PROTO_ANYNET     = 63           # any local network
  IP_PROTO_EXPAK      = 64           # SATNET and Backroom EXPAK
  IP_PROTO_KRYPTOLAN  = 65           # Kryptolan
  IP_PROTO_RVD        = 66           # MIT Remote Virtual Disk
  IP_PROTO_IPPC       = 67           # Inet Pluribus Packet Core
  IP_PROTO_DISTFS     = 68           # any distributed fs
  IP_PROTO_SATMON     = 69           # SATNET Monitoring
  IP_PROTO_VISA       = 70           # VISA Protocol
  IP_PROTO_IPCV       = 71           # Inet Packet Core Utility
  IP_PROTO_CPNX       = 72           # Comp Proto Net Executive
  IP_PROTO_CPHB       = 73           # Comp Protocol Heart Beat
  IP_PROTO_WSN        = 74           # Wang Span Network
  IP_PROTO_PVP        = 75           # Packet Video Protocol
  IP_PROTO_BRSATMON   = 76           # Backroom SATNET Monitor
  IP_PROTO_SUNND      = 77           # SUN ND Protocol
  IP_PROTO_WBMON      = 78           # WIDEBAND Monitoring
  IP_PROTO_WBEXPAK    = 79           # WIDEBAND EXPAK
  IP_PROTO_EON        = 80           # ISO CNLP
  IP_PROTO_VMTP       = 81           # Versatile Msg Transport
  IP_PROTO_SVMTP      = 82           # Secure VMTP
  IP_PROTO_VINES      = 83           # VINES
  IP_PROTO_TTP        = 84           # TTP
  IP_PROTO_NSFIGP     = 85           # NSFNET-IGP
  IP_PROTO_DGP        = 86           # Dissimilar Gateway Proto
  IP_PROTO_TCF        = 87           # TCF
  IP_PROTO_EIGRP      = 88           # EIGRP
  IP_PROTO_OSPF       = 89           # Open Shortest Path First
  IP_PROTO_SPRITERPC  = 90           # Sprite RPC Protocol
  IP_PROTO_LARP       = 91           # Locus Address Resolution
  IP_PROTO_MTP        = 92           # Multicast Transport Proto
  IP_PROTO_AX25       = 93           # AX.25 Frames
  IP_PROTO_IPIPENCAP  = 94           # yet-another IP encap
  IP_PROTO_MICP       = 95           # Mobile Internet Ctrl
  IP_PROTO_SCCSP      = 96           # Semaphore Comm Sec Proto
  IP_PROTO_ETHERIP    = 97           # Ethernet in IPv4
  IP_PROTO_ENCAP      = 98           # encapsulation header
  IP_PROTO_ANYENC     = 99           # private encryption scheme
  IP_PROTO_GMTP       = 100          # GMTP
  IP_PROTO_IFMP       = 101          # Ipsilon Flow Mgmt Proto
  IP_PROTO_PNNI       = 102          # PNNI over IP
  IP_PROTO_PIM        = 103          # Protocol Indep Multicast
  IP_PROTO_ARIS       = 104          # ARIS
  IP_PROTO_SCPS       = 105          # SCPS
  IP_PROTO_QNX        = 106          # QNX
  IP_PROTO_AN         = 107          # Active Networks
  IP_PROTO_IPCOMP     = 108          # IP Payload Compression
  IP_PROTO_SNP        = 109          # Sitara Networks Protocol
  IP_PROTO_COMPAQPEER = 110          # Compaq Peer Protocol
  IP_PROTO_IPXIP      = 111          # IPX in IP
  IP_PROTO_VRRP       = 112          # Virtual Router Redundancy
  IP_PROTO_PGM        = 113          # PGM Reliable Transport
  IP_PROTO_ANY0HOP    = 114          # 0-hop protocol
  IP_PROTO_L2TP       = 115          # Layer 2 Tunneling Proto
  IP_PROTO_DDX        = 116          # D-II Data Exchange (DDX)
  IP_PROTO_IATP       = 117          # Interactive Agent Xfer
  IP_PROTO_STP        = 118          # Schedule Transfer Proto
  IP_PROTO_SRP        = 119          # SpectraLink Radio Proto
  IP_PROTO_UTI        = 120          # UTI
  IP_PROTO_SMP        = 121          # Simple Message Protocol
  IP_PROTO_SM         = 122          # SM
  IP_PROTO_PTP        = 123          # Performance Transparency
  IP_PROTO_ISIS       = 124          # ISIS over IPv4
  IP_PROTO_FIRE       = 125          # FIRE
  IP_PROTO_CRTP       = 126          # Combat Radio Transport
  IP_PROTO_CRUDP      = 127          # Combat Radio UDP
  IP_PROTO_SSCOPMCE   = 128          # SSCOPMCE
  IP_PROTO_IPLT       = 129          # IPLT
  IP_PROTO_SPS        = 130          # Secure Packet Shield
  IP_PROTO_PIPE       = 131          # Private IP Encap in IP
  IP_PROTO_SCTP       = 132          # Stream Ctrl Transmission
  IP_PROTO_FC         = 133          # Fibre Channel
  IP_PROTO_RSVPIGN    = 134          # RSVP-E2E-IGNORE
  IP_PROTO_RAW        = 255          # Raw IP packets

  IP_PROTO_RESERVED   = IP_PROTO_RAW # Reserved
  IP_PROTO_HOPOPTS    = IP_PROTO_IP  # IPv6 hop-by-hop options

 
  # Option types (opt_type) - http://www.iana.org/assignments/ip-parameters

  IP_OPT_CONTROL   = 0x00 # control
  IP_OPT_DEBMEAS   = 0x40 # debugging & measurement
  IP_OPT_COPY      = 0x80 # copy into all fragments
  IP_OPT_RESERVED1 = 0x20
  IP_OPT_RESERVED2 = 0x60

  IP_OPT_EOL    = 0                               # terminates option list
  IP_OPT_NOP    = 1                               # no operation
  IP_OPT_SEC    = (2|IP_OPT_COPY)                 # DoD basic security
  IP_OPT_LSRR   = (3|IP_OPT_COPY)                 # loose source route
  IP_OPT_TS     = (4|IP_OPT_DEBMEAS)              # timestamp
  IP_OPT_ESEC   = (5|IP_OPT_COPY)                 # DoD extended security
  IP_OPT_CIPSO  = (6|IP_OPT_COPY)                 # commercial security
  IP_OPT_RR     = 7                               # record route
  IP_OPT_SATID  = (8|IP_OPT_COPY)                 # stream ID (obsolete)
  IP_OPT_SSRR   = (9|IP_OPT_COPY)                 # strict source route
  IP_OPT_ZSU    = 10                              # experimental measurement
  IP_OPT_MTUP   = 11                              # MTU probe
  IP_OPT_MTUR   = 12                              # MTU reply
  IP_OPT_FINN   = (13|IP_OPT_COPY|IP_OPT_DEBMEAS) # exp flow control
  IP_OPT_VISA   = (14|IP_OPT_COPY)                # exp access control
  IP_OPT_ENCODE = 15                              # ???
  IP_OPT_IMITD  = (16|IP_OPT_COPY)                # IMI traffic descriptor
  IP_OPT_EIP    = (17|IP_OPT_COPY)                # extended IP, RFC 1385
  IP_OPT_TR     = (18|IP_OPT_DEBMEAS)             # traceroute
  IP_OPT_ADDEXT = (19|IP_OPT_COPY)                # IPv7 ext addr, RFC 1475
  IP_OPT_RTRALT = (20|IP_OPT_COPY)                # router alert, RFC 2113
  IP_OPT_SDB    = (21|IP_OPT_COPY)                # directed bcast, RFC 1770
  IP_OPT_NSAPA  = (22|IP_OPT_COPY)                # NSAP addresses
  IP_OPT_DPS    = (23|IP_OPT_COPY)                # dynamic packet state
  IP_OPT_UMP    = (24|IP_OPT_COPY)                # upstream multicast
  IP_OPT_MAX    = 25


  # Security option data - RFC 791, 3.1

  #  struct ip_opt_data_sec {
  #    uint16_t	s;		/* security */
  #    uint16_t	c;		/* compartments */
  #    uint16_t	h;		/* handling restrictions */
  #    uint8_t		tcc[3];		/* transmission control code */
  #  } __attribute__((__packed__));


  IP_OPT_SEC_UNCLASS   = 0x0000 # unclassified
  IP_OPT_SEC_CONFID    = 0xf135 # confidential
  IP_OPT_SEC_EFTO      = 0x789a # EFTO
  IP_OPT_SEC_MMMM      = 0xbc4d # MMMM
  IP_OPT_SEC_PROG      = 0x5e26 # PROG
  IP_OPT_SEC_RESTR     = 0xaf13 # restricted
  IP_OPT_SEC_SECRET    = 0xd788 # secret
  IP_OPT_SEC_TOPSECRET = 0x6bc5 # top secret


  # {Loose Source, Record, Strict Source} Route option data - RFC 791, 3.1

  # struct ip_opt_data_rr {
  # 	uint8_t		ptr;		/* from start of option, >= 4 */
  # 	uint32_t	iplist __flexarr; /* list of IP addresses */
  # } __attribute__((__packed__));


  # Timestamp option data - RFC 791, 3.1

  # struct ip_opt_data_ts {
  # 	uint8_t		ptr;		  /* from start of option, >= 5 */
  # 	uint8_t		oflw:4,		/* number of IPs skipped */
  # 	    		  flg:4;		/* address[ / timestamp] flag */
  # 	uint32_t	ipts __flexarr;	/* IP address [/ timestamp] pairs */
  # } __attribute__((__packed__));
  # 

  IP_OPT_TS_TSONLY  = 0 # timestamps only
  IP_OPT_TS_TSADDR  = 1 # IP address / timestamp pairs
  IP_OPT_TS_PRESPEC = 3 # IP address / zero timestamp pairs


  #  Traceroute option data - RFC 1393, 2.2

  # struct ip_opt_data_tr {
  # 	uint16_t	id;		/* ID number */
  # 	uint16_t	ohc;		/* outbound hop count */
  # 	uint16_t	rhc;		/* return hop count */
  # 	uint32_t	origip;		/* originator IP address */
  # } __attribute__((__packed__));


  # IP option (following IP header)

  # struct ip_opt {
  # 	uint8_t		opt_type;	/* option type */
  # 	uint8_t		opt_len;	/* option length >= IP_OPT_LEN */
  # 	union ip_opt_data {
  # 		struct ip_opt_data_sec	sec;	   /* IP_OPT_SEC */
  # 		struct ip_opt_data_rr	rr;	   /* IP_OPT_{L,S}RR */
  # 		struct ip_opt_data_ts	ts;	   /* IP_OPT_TS */
  # 		uint16_t		satid;	   /* IP_OPT_SATID */
  # 		uint16_t		mtu;	   /* IP_OPT_MTU{P,R} */
  # 		struct ip_opt_data_tr	tr;	   /* IP_OPT_TR */
  # 		uint32_t		addext[2]; /* IP_OPT_ADDEXT */
  # 		uint16_t		rtralt;    /* IP_OPT_RTRALT */
  # 		uint32_t		sdb[9];    /* IP_OPT_SDB */
  # 		uint8_t			data8[IP_OPT_LEN_MAX - IP_OPT_LEN];
  # 	} opt_data;
  # } __attribute__((__packed__));
  # 

  ######################################################################
  ### include/dnet/ip6.h
  ######################################################################
  IP6_ADDR_LEN  = 16
  IP6_ADDR_BITS = 128

  IP6_HDR_LEN   = 40          # IPv6 header length
  IP6_LEN_MIN   = IP6_HDR_LEN
  IP6_LEN_MAX   = 65535       # non-jumbo payload

  IP6_MTU_MIN   = 1280        # minimum MTU (1024 + 256)
    
  IP6_VERSION      = 0x60
  IP6_VERSION_MASK = 0xf0     # ip6_vfc version
    

  # Hop limit (ip6_hlim)
  IP6_HLIM_DEFAULT =	64
  IP6_HLIM_MAX		 = 255


  # Fragmentation offset, reserved, and flags (offlg)

  IP6_OFF_MASK      = 0xfff8  # mask out offset from offlg
  IP6_RESERVED_MASK = 0x0006  # reserved bits in offlg
  IP6_MORE_FRAG     = 0x0001  # more-fragments flag


  # XXX implement? IP6_OPT_TYPE(o)
  #define IP6_OPT_TYPE(o)		((o) & 0xC0)	/* high 2 bits of opt_type */

  IP6_OPT_PAD1           = 0x00   # 00 0 00000
  IP6_OPT_PADN           = 0x01   # 00 0 00001
  IP6_OPT_JUMBO          = 0xC2   # 11 0 00010 = 194
  IP6_OPT_JUMBO_LEN      = 6
  IP6_OPT_RTALERT        = 0x05   # 00 0 00101
  IP6_OPT_RTALERT_LEN    = 4
  IP6_OPT_RTALERT_MLD    = 0      # Datagram contains an MLD message
  IP6_OPT_RTALERT_RSVP   = 1      # Datagram contains an RSVP message
  IP6_OPT_RTALERT_ACTNET = 2      # contains an Active Networks msg
  IP6_OPT_LEN_MIN        = 2

  IP6_OPT_TYPE_SKIP      = 0x00   # continue processing on failure
  IP6_OPT_TYPE_DISCARD   = 0x40   # discard packet on failure
  IP6_OPT_TYPE_FORCEICMP = 0x80   # discard and send ICMP on failure
  IP6_OPT_TYPE_ICMP      = 0xC0   # ...only if non-multicast dst

  IP6_OPT_MUTABLE        = 0x20   # option data may change en route


  ######################################################################
  ### include/dnet/rand.h
  ######################################################################



  ######################################################################
  ### include/dnet/tcp.h
  ######################################################################

  TCP_HDR_LEN     = 20    # base TCP header length
  TCP_OPT_LEN     = 2    # base TCP option length
  TCP_OPT_LEN_MAX = 40
  TCP_HDR_LEN_MAX = (TCP_HDR_LEN + TCP_OPT_LEN_MAX)

  TCP_PORT_MAX = 65535    # maximum port
  TCP_WIN_MAX  = 65535    # maximum (unscaled) window

  TH_FIN   = 0x01    # terminates data
  TH_SYN   = 0x02    # synchronize sequence numbers
  TH_RST   = 0x04    # reset connection
  TH_PUSH  = 0x08    # push
  TH_ACK   = 0x10    # acknowledgment number set
  TH_URG   = 0x20    # urgent pointer set
  TH_ECE   = 0x40    # ECN echo, RFC 3168
  TH_CWR   = 0x80    # congestion window reduced


  # TCP FSM states

  TCP_STATE_CLOSED       = 0    # closed
  TCP_STATE_LISTEN       = 1    # listening from connection
  TCP_STATE_SYN_SENT     = 2    # active, have sent SYN
  TCP_STATE_SYN_RECEIVED = 3    # have sent and received SYN

  TCP_STATE_ESTABLISHED  = 4    # established
  TCP_STATE_CLOSE_WAIT   = 5    # rcvd FIN, waiting for close

  TCP_STATE_FIN_WAIT_1   = 6    # have closed, sent FIN
  TCP_STATE_CLOSING      = 7    # closed xchd FIN, await FIN-ACK
  TCP_STATE_LAST_ACK     = 8    # had FIN and close, await FIN-ACK

  TCP_STATE_FIN_WAIT_2   = 9    # have closed, FIN is acked
  TCP_STATE_TIME_WAIT    = 10   # in 2*MSL quiet wait after close

  TCP_STATE_MAX          = 11


  # Options (opt_type) - http://www.iana.org/assignments/tcp-parameters

  TCP_OPT_EOL        = 0    # end of option list
  TCP_OPT_NOP        = 1    # no operation
  TCP_OPT_MSS        = 2    # maximum segment size
  TCP_OPT_WSCALE     = 3    # window scale factor, RFC 1072
  TCP_OPT_SACKOK     = 4    # SACK permitted, RFC 2018
  TCP_OPT_SACK       = 5    # SACK, RFC 2018
  TCP_OPT_ECHO       = 6    # echo (obsolete), RFC 1072
  TCP_OPT_ECHOREPLY  = 7    # echo reply (obsolete), RFC 1072
  TCP_OPT_TIMESTAMP  = 8    # timestamp, RFC 1323
  TCP_OPT_POCONN     = 9    # partial order conn, RFC 1693
  TCP_OPT_POSVC      = 10   # partial order service, RFC 1693
  TCP_OPT_CC         = 11   # connection count, RFC 1644
  TCP_OPT_CCNEW      = 12   # CC.NEW, RFC 1644
  TCP_OPT_CCECHO     = 13   # CC.ECHO, RFC 1644
  TCP_OPT_ALTSUM     = 14   # alt checksum request, RFC 1146
  TCP_OPT_ALTSUMDATA = 15   # alt checksum data, RFC 1146
  TCP_OPT_SKEETER    = 16   # Skeeter
  TCP_OPT_BUBBA      = 17   # Bubba
  TCP_OPT_TRAILSUM   = 18   # trailer checksum
  TCP_OPT_MD5        = 19   # MD5 signature, RFC 2385
  TCP_OPT_SCPS       = 20   # SCPS capabilities
  TCP_OPT_SNACK      = 21   # selective negative acks
  TCP_OPT_REC        = 22   # record boundaries
  TCP_OPT_CORRUPT    = 23   # corruption experienced
  TCP_OPT_SNAP       = 24   # SNAP
  TCP_OPT_TCPCOMP    = 26   # TCP compression filter
  TCP_OPT_MAX        = 27


  ######################################################################
  ### include/dnet/udp.h
  ######################################################################

  UDP_HDR_LEN  = 8
  UDP_PORT_MAX = 65535

end
