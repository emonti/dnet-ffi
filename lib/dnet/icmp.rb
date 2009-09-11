
module Dnet::Icmp

  # ICMP header structure
  #
  #   struct icmp_hdr {
  #     uint8_t    icmp_type;  /* type of message */
  #     uint8_t    icmp_code;  /* type sub code */
  #     uint16_t  icmp_cksum;  /* ones complement cksum of struct */
  #   };
  #
  class Hdr < ::Dnet::SugarStruct
    layout( :icmp_type,   :uint8,
            :icmp_code,    :uint8,
            :icmp_cksum,   :uint16 )

    module IcmpType
      include ::Dnet::ConstMap
      slurp_constants(::Dnet, "ICMP_TYPE_")
      def list; @@list ||= super(); end
    end

    module IcmpCode
      module UNREACH
        include ::Dnet::ConstMap
        slurp_constants(::Dnet, "ICMP_UNREACH_")
        def list; @@list ||= super(); end
      end

      module REDIRECT
        include ::Dnet::ConstMap
        slurp_constants(::Dnet, "ICMP_REDIRECT_")
        def list; @@list ||= super(); end
      end

      module RTRADVERT
        include ::Dnet::ConstMap
        slurp_constants(::Dnet, "ICMP_RTRADVERT_")
        def list; @@list ||= super(); end
      end

      module TIMEEXCEED
        include ::Dnet::ConstMap
        slurp_constants(::Dnet, "ICMP_TIMEEXCEED_")
        def list; @@list ||= super(); end
      end

      module PARAMPROB
        include ::Dnet::ConstMap
        slurp_constants(::Dnet, "ICMP_PARAMPROB_")
        def list; @@list ||= super(); end
      end

      module PHOTURIS
        include ::Dnet::ConstMap
        slurp_constants(::Dnet, "ICMP_PHOTURIS_")
        def list; @@list ||= super(); end
      end

    end # module IcmpCode

    # Various ICMP message structures
    module Msg

      # Echo message data structure
      # 
      #   struct icmp_msg_echo {
      #     uint16_t  icmp_id;
      #     uint16_t  icmp_seq;
      #     uint8_t   icmp_data __flexarr;  /* optional data */
      #   };
      # 
      class Echo < ::Dnet::SugarStruct
        layout( :icmp_id, :uint16,
                :seq,     :uint16,
                :data,    :uint8 )  # flexarr ... optional data
      end

      # Fragmentation-needed (unreachable) message data structure
      # 
      #   struct icmp_msg_needfrag {
      #     uint16_t  icmp_void;    /* must be zero */
      #     uint16_t  icmp_mtu;    /* MTU of next-hop network */
      #     uint8_t   icmp_ip __flexarr;  /* IP hdr + 8 bytes of pkt */
      #   };
      # 
      class NeedFrag < ::Dnet::SugarStruct
        layout( :icmp_void, :uint16,
                :mtu,       :uint16,
                :ip,        :uint8 )  # flexarr ... IP hdr + 8 bytes of pkt
      end

      # Unreachable, source quench, redirect, time exceeded,
      # parameter problem message data structure
      # 
      #   struct icmp_msg_quote {
      #     uint32_t  icmp_void;    /* must be zero */
      #     uint8_t   icmp_ip __flexarr;  /* IP hdr + 8 bytes of pkt */
      #   };
      # 
      class Quote < ::Dnet::SugarStruct
        layout( :icmp_void, :uint32,
                :ip,        :uint8 )   # flexxarr ... IP hdr + 8 bytes of pkt
      end

      # Router advertisement message data structure, RFC 1256
      # 
      #   struct icmp_msg_rtradvert {
      #     uint8_t    icmp_num_addrs;    /* # of address / pref pairs */
      #     uint8_t    icmp_wpa;    /* words / address == 2 */
      #     uint16_t   icmp_lifetime;    /* route lifetime in seconds */
      #     struct icmp_msg_rtr_data {
      #       uint32_t  icmp_void;
      #       uint32_t  icmp_pref;  /* router preference (usu 0) */
      #     } icmp_rtr __flexarr;      /* variable # of routers */
      #   };
      # 
      class RtrAdvert < ::Dnet::SugarStruct

        class RtrData < ::Dnet::SugarStruct
          layout( :icmp_void, :uint32,
                  :pref,      :uint32 )
        end

        layout( :num_addrs, :uint8,
                :wpa,       :uint8,
                :lifetime,  :uint16,
                :router,    RtrData )  # flexarr ... variable # of routers
      end

      # Timestamp message data structure
      # 
      #   struct icmp_msg_tstamp {
      #     uint32_t  icmp_id;    /* identifier */
      #     uint32_t  icmp_seq;    /* sequence number */
      #     uint32_t  icmp_ts_orig;    /* originate timestamp */
      #     uint32_t  icmp_ts_rx;    /* receive timestamp */
      #     uint32_t  icmp_ts_tx;    /* transmit timestamp */
      #   };
      # 
      class Timestamp < ::Dnet::SugarStruct
        layout( :icmp_id, :uint32,
                :seq,     :uint32,
                :ts_orig, :uint32,
                :ts_rx,   :uint32,
                :ts_tx,   :uint32 )
      end

      # Address mask message data structure, RFC 950
      # 
      #   struct icmp_msg_mask {
      #     uint32_t  icmp_id;    /* identifier */
      #     uint32_t  icmp_seq;    /* sequence number */
      #     uint32_t  icmp_mask;    /* address mask */
      #   };
      # 
      class Mask < ::Dnet::SugarStruct
        layout( :icmp_id, :uint32,
                :seq,     :uint32,
                :mask,    :uint32 )
      end

      # Traceroute message data structure, RFC 1393, RFC 1812
      # 
      #   struct icmp_msg_traceroute {
      #     uint16_t  icmp_id;    /* identifier */
      #     uint16_t  icmp_void;    /* unused */
      #     uint16_t  icmp_ohc;    /* outbound hop count */
      #     uint16_t  icmp_rhc;    /* return hop count */
      #     uint32_t  icmp_speed;    /* link speed, bytes/sec */
      #     uint32_t  icmp_mtu;    /* MTU in bytes */
      #   };
      # 
      class Traceroute < ::Dnet::SugarStruct
        layout( :icmp_id,   :uint16,
                :icmp_void, :uint16,
                :ohc,       :uint16,
                :rhc,       :uint16,
                :speed,     :uint16,
                :mtu,       :uint16 )
      end

      # Domain name reply message data structure, RFC 1788
      # 
      #   struct icmp_msg_dnsreply {
      #     uint16_t  icmp_id;    /* identifier */
      #     uint16_t  icmp_seq;    /* sequence number */
      #     uint32_t  icmp_ttl;    /* time-to-live */
      #     uint8_t    icmp_names __flexarr;  /* variable number of names */
      #   };
      # 
      class DnsReply < ::Dnet::SugarStruct
        layout( :icmp_id, :uint16,
                :seq,     :uint16,
                :ttl,     :uint16,
                :names,   :uint8 )  # flexarr ... variable # of names
      end

      # Generic identifier, sequence number data structure
      # 
      #   struct icmp_msg_idseq {
      #     uint16_t  icmp_id;
      #     uint16_t  icmp_seq;
      #   };
      # 
      class IdSeq < ::Dnet::SugarStruct
        layout( :icmp_id, :uint16,
                :seq,     :uint16 )
      end

    end # module Msg
  end

  # /*
  #  * ICMP message union
  #  */
  # union icmp_msg {
  #   struct icmp_msg_echo     echo;  /* ICMP_ECHO{REPLY} */
  #   struct icmp_msg_quote     unreach;  /* ICMP_UNREACH */
  #   struct icmp_msg_needfrag   needfrag;  /* ICMP_UNREACH_NEEDFRAG */
  #   struct icmp_msg_quote     srcquench;  /* ICMP_SRCQUENCH */
  #   struct icmp_msg_quote     redirect;  /* ICMP_REDIRECT (set to 0) */
  #   uint32_t       rtrsolicit;  /* ICMP_RTRSOLICIT */
  #   struct icmp_msg_rtradvert  rtradvert;  /* ICMP_RTRADVERT */
  #   struct icmp_msg_quote     timexceed;  /* ICMP_TIMEXCEED */
  #   struct icmp_msg_quote     paramprob;  /* ICMP_PARAMPROB */
  #   struct icmp_msg_tstamp     tstamp;  /* ICMP_TSTAMP{REPLY} */
  #   struct icmp_msg_idseq     info;  /* ICMP_INFO{REPLY} */
  #   struct icmp_msg_mask     mask;  /* ICMP_MASK{REPLY} */
  #   struct icmp_msg_traceroute traceroute;  /* ICMP_TRACEROUTE */
  #   struct icmp_msg_idseq     dns;    /* ICMP_DNS */
  #   struct icmp_msg_dnsreply   dnsreply;  /* ICMP_DNSREPLY */
  # };

  # #define icmp_pack_hdr(hdr, type, code) do {        \
  #   struct icmp_hdr *icmp_pack_p = (struct icmp_hdr *)(hdr);  \
  #   icmp_pack_p->icmp_type = type; icmp_pack_p->icmp_code = code;  \
  # } while (0)

  # #define icmp_pack_hdr_echo(hdr, type, code, id, seq, data, len) do {  \
  #   struct icmp_msg_echo *echo_pack_p = (struct icmp_msg_echo *)  \
  #     ((uint8_t *)(hdr) + ICMP_HDR_LEN);      \
  #   icmp_pack_hdr(hdr, type, code);          \
  #   echo_pack_p->icmp_id = htons(id);        \
  #   echo_pack_p->icmp_seq = htons(seq);        \
  #   memmove(echo_pack_p->icmp_data, data, len);      \
  # } while (0)


end # module Dnet::Icmp
