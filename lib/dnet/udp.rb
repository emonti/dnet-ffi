module Dnet

  class Udp
    class Hdr < ::Dnet::SugarHelper
      # struct udp_hdr {
      #   uint16_t	uh_sport;	/* source port */
      #  	uint16_t	uh_dport;	/* destination port */
      #  	uint16_t	uh_ulen;	/* udp length (including header) */
      #  	uint16_t	uh_sum;		/* udp checksum */
      # };
      layout( :sport,   :uint16,
              :dport,   :uint16,
              :len,     :uint16,
              :sum,     :uint16 )
    end
  end


  #  #define udp_pack_hdr(hdr, sport, dport, ulen) do {		\
  #  	struct udp_hdr *udp_pack_p = (struct udp_hdr *)(hdr);	\
  #  	udp_pack_p->uh_sport = htons(sport);			\
  #  	udp_pack_p->uh_dport = htons(dport);			\
  #  	udp_pack_p->uh_ulen = htons(ulen);			\
  #  } while (0)

end
