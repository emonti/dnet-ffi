module Dnet
  module Tcp

    # TCP header, without options
    class Hdr < ::Dnet::SugarStruct
      #  struct tcp_hdr {
      #      uint16_t    th_sport;    /* source port */
      #      uint16_t    th_dport;    /* destination port */
      #      uint32_t    th_seq;      /* sequence number */
      #      uint32_t    th_ack;      /* acknowledgment number */
      #      uint8_t     th_off:4,    /* data offset */
      #                  th_x2:4;     /* (unused) */
      #      uint8_t     th_flags;    /* control flags */
      #      uint16_t    th_win;      /* window */
      #      uint16_t    th_sum;      /* checksum */
      #      uint16_t    th_urp;      /* urgent pointer */
      #  };
      layout( :sport,   :uint16,
              :dport,   :uint16,
              :seq,     :uint32,
              :ack,     :uint32,
              :off,     :uint8,   # data offset(. & 0xf0) unused (. & 0x0f)
              :flags,   :uint8,
              :win,     :uint16,
              :sum,     :uint16,
              :urgp,    :uint16 ) # urgent pointer

      # TCP control flags (flags)
      module Flags
        include ConstList
        slurp_constants(::Dnet, "TH_")
        def self.list; @@list ||= _list ; end
      end

      #  #define \
      #    tcp_pack_hdr(hdr, sport, dport, seq, ack, flags, win, urp) do { \
      #      struct tcp_hdr *tcp_pack_p = (struct tcp_hdr *)(hdr);    \
      #      tcp_pack_p->th_sport = htons(sport);                     \
      #      tcp_pack_p->th_dport = htons(dport);                     \
      #      tcp_pack_p->th_seq = htonl(seq);                         \
      #      tcp_pack_p->th_ack = htonl(ack);                         \
      #      tcp_pack_p->th_x2 = 0; tcp_pack_p->th_off = 5;           \
      #      tcp_pack_p->th_flags = flags;                            \
      #      tcp_pack_p->th_win = htons(win);                         \
      #      tcp_pack_p->th_urp = htons(urp);                         \
      #  } while (0)

    end

    #
    # TCP option (following TCP header)
    #
    #   struct tcp_opt {
    #      uint8_t        opt_type;  /* option type */
    #      uint8_t        opt_len;   /* option length >= TCP_OPT_LEN */
    #      union tcp_opt_data {
    #        uint16_t    mss;           /* TCP_OPT_MSS */
    #        uint8_t        wscale;     /* TCP_OPT_WSCALE */
    #        uint16_t    sack[19];      /* TCP_OPT_SACK */
    #        uint32_t    echo;          /* TCP_OPT_ECHO{REPLY} */
    #        uint32_t    timestamp[2];  /* TCP_OPT_TIMESTAMP */
    #        uint32_t    cc;            /* TCP_OPT_CC{NEW,ECHO} */
    #        uint8_t        cksum;      /* TCP_OPT_ALTSUM */
    #        uint8_t        md5[16];    /* TCP_OPT_MD5 */
    #        uint8_t        data8[TCP_OPT_LEN_MAX - TCP_OPT_LEN];
    #      } opt_data;
    #   } __attribute__((__packed__));
    #
    class Opt < ::Dnet::SugarStruct
      layout( :otype,   :uint8,
              :len,     :uint8,
              :data8,   [:uint8, (TCP_OPT_LEN_MAX - TCP_OPT_LEN)] )


      # Options (otype) - http://www.iana.org/assignments/tcp-parameters
      module Otype
        include ConstList
        slurp_constants(::Dnet, "TCP_OTYPE_")
        def self.list; @@list ||= _list ; end
      end

    end # Opt

    # TCP FSM states
    module State
      include ConstList
      slurp_constants(::Dnet, "TCP_STATE_")
      def self.list; @@list ||= _list ; end
    end

  end # Tcp
end # Dnet

