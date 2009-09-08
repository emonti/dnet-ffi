module Dnet

  # /*
  #  * TCP header, without options
  #  */
  #  struct tcp_hdr {
  #      uint16_t    th_sport;    /* source port */
  #      uint16_t    th_dport;    /* destination port */
  #      uint32_t    th_seq;      /* sequence number */
  #      uint32_t    th_ack;      /* acknowledgment number */
  #  #if DNET_BYTESEX == DNET_BIG_ENDIAN
  #      uint8_t        th_off:4, /* data offset */
  #                     th_x2:4;  /* (unused) */
  #  #elif DNET_BYTESEX == DNET_LIL_ENDIAN
  #      uint8_t        th_x2:4,
  #                     th_off:4;
  #  #else
  #  # error "need to include <dnet.h>"
  #  #endif
  #      uint8_t        th_flags; /* control flags */
  #      uint16_t    th_win;      /* window */
  #      uint16_t    th_sum;      /* checksum */
  #      uint16_t    th_urp;      /* urgent pointer */
  #  };

  #  /*
  #   * TCP option (following TCP header)
  #   */
  #  struct tcp_opt {
  #    uint8_t        opt_type;  /* option type */
  #    uint8_t        opt_len;   /* option length >= TCP_OPT_LEN */
  #    union tcp_opt_data {
  #      uint16_t    mss;           /* TCP_OPT_MSS */
  #      uint8_t        wscale;     /* TCP_OPT_WSCALE */
  #      uint16_t    sack[19];      /* TCP_OPT_SACK */
  #      uint32_t    echo;          /* TCP_OPT_ECHO{REPLY} */
  #      uint32_t    timestamp[2];  /* TCP_OPT_TIMESTAMP */
  #      uint32_t    cc;            /* TCP_OPT_CC{NEW,ECHO} */
  #      uint8_t        cksum;      /* TCP_OPT_ALTSUM */
  #      uint8_t        md5[16];    /* TCP_OPT_MD5 */
  #      uint8_t        data8[TCP_OPT_LEN_MAX - TCP_OPT_LEN];
  #    } opt_data;
  #  } __attribute__((__packed__));


  #  #define tcp_pack_hdr(hdr, sport, dport, seq, ack, flags, win, urp) do { \
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

  #  /*
  #   * Sequence number comparison macros
  #   */
  #  #define TCP_SEQ_LT(a,b)        ((int)((a)-(b)) < 0)
  #  #define TCP_SEQ_LEQ(a,b)    ((int)((a)-(b)) <= 0)
  #  #define TCP_SEQ_GT(a,b)        ((int)((a)-(b)) > 0)
  #  #define TCP_SEQ_GEQ(a,b)    ((int)((a)-(b)) >= 0)
  #
 
 
end

