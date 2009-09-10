
### libdnet's IP interface

module Dnet

  module Ip

    # IP header, without options
    #
    #   struct ip_hdr {
    #     uint8_t    ip_v:4,   /* version */
    #                ip_hl:4;  /* header length (incl any options) */
    #     uint8_t    ip_tos;   /* type of service */
    #     uint16_t   ip_len;   /* total length (incl header) */
    #     uint16_t   ip_id;    /* identification */
    #     uint16_t   ip_off;   /* fragment offset and flags */
    #     uint8_t    ip_ttl;   /* time to live */
    #     uint8_t    ip_p;     /* protocol */
    #     uint16_t   ip_sum;   /* checksum */
    #     ip_addr_t  ip_src;   /* source address */
    #     ip_addr_t  ip_dst;   /* destination address */
    #   };
    #
    class Hdr < ::Dnet::SugarStruct
      layout( :v_hl,    :uint8,       # v=vers(. & 0xf0) / hl=hdr len(. & 0x0f)
              :tos,     :uint8,       # type of service
              :len,     :uint16,      # total length (incl header)
              :id,      :uint16,      # identification
              :off,     :uint16,      # fragment offset and flags
              :ttl,     :uint8,       # time to live
              :proto,   :uint8,       # protocol
              :sum,     :uint16,      # checksum
              :src,     :uint32,      # source address
              :dst,     :uint32 )     # destination address

      # Type of service (ip_tos), RFC 1349 ("obsoleted by RFC 2474")
      #
      # Contains mappings for all the IP_TOS_[A-Z].* constants
      module Tos
        include ConstList
        slurp_constants(::Dnet, "IP_TOS_")
        def self.list;  @@list ||= super(); end
      end

      # Protocols (proto) - http://www.iana.org/assignments/protocol-numbers
      #
      # Contains mappings for all the IP_PROTO_[A-Z].* constants
      module Proto
        include ConstList
        slurp_constants(::Dnet, "IP_PROTO_")
        def self.list;  @@list ||= super(); end
      end

      # #define ip_pack_hdr(hdr, tos, len, id, off, ttl, p, src, dst) do {  \
      # struct ip_hdr *ip_pack_p = (struct ip_hdr *)(hdr);    \
      #   ip_pack_p->ip_v = 4; ip_pack_p->ip_hl = 5;      \
      #   ip_pack_p->ip_tos = tos; ip_pack_p->ip_len = htons(len);  \
      #   ip_pack_p->ip_id = htons(id); ip_pack_p->ip_off = htons(off);  \
      #   ip_pack_p->ip_ttl = ttl; ip_pack_p->ip_p = p;      \
      #   ip_pack_p->ip_src = src; ip_pack_p->ip_dst = dst;    \
      # } while (0)
    end # class Hdr


    # IP option (following IP header)
    #
    #   struct ip_opt {
    #     uint8_t    opt_type;  /* option type */
    #     uint8_t    opt_len;   /* option length >= IP_OPT_LEN */
    #     union ip_opt_data {
    #       struct ip_opt_data_sec  sec;        /* IP_OPT_SEC */
    #       struct ip_opt_data_rr   rr;         /* IP_OPT_{L,S}RR */
    #       struct ip_opt_data_ts   ts;         /* IP_OPT_TS */
    #       uint16_t                satid;      /* IP_OPT_SATID */
    #       uint16_t                mtu;        /* IP_OPT_MTU{P,R} */
    #       struct ip_opt_data_tr   tr;         /* IP_OPT_TR */
    #       uint32_t                addext[2];  /* IP_OPT_ADDEXT */
    #       uint16_t                rtralt;     /* IP_OPT_RTRALT */
    #       uint32_t                sdb[9];     /* IP_OPT_SDB */
    #       uint8_t                 data8[IP_OPT_LEN_MAX - IP_OPT_LEN];
    #     } opt_data;
    #   } __attribute__((__packed__));
    #
    class Opt < ::Dnet::SugarStruct
      layout( :otype,   :uint8,     # option type
              :len,     :uint8,     # option length
              :data,    [:uint8, (IP_OPT_LEN_MAX - IP_OPT_LEN)] )


      # Option types (otype) - http://www.iana.org/assignments/ip-parameters
      #
      # Contains mappings for all the IP_OTYPE_[A-Z].* constants
      module Otype
        include ConstList
        slurp_constants(::Dnet, "IP_OTYPE_")
        def self.list;  @@list ||= super(); end
      end

      # Security option data - RFC 791, 3.1
      #
      #   struct ip_opt_data_sec {
      #     uint16_t  sec;    /* security */
      #     uint16_t  cpt;    /* compartments */
      #     uint16_t  hr;     /* handling restrictions */
      #     uint8_t   tcc[3]; /* transmission control code */
      #   } __attribute__((__packed__));
      #
      class DataSEC < ::Dnet::SugarStruct
        layout( :sec,   :uint16,
                :cpt,   :uint16,
                :hr,    :uint16,
                :tcc,   [:uint8, 3] )

      end

      # Timestamp option data - RFC 791, 3.1
      #
      #   struct ip_opt_data_ts {
      #     uint8_t    ptr;    /* from start of option, >= 5 */
      #     uint8_t    oflw:4,    /* number of IPs skipped */
      #                flg:4;    /* address[ / timestamp] flag */
      #     uint32_t   ipts __flexarr;  /* IP address [/ timestamp] pairs */
      #   } __attribute__((__packed__));
      #
      class DataTS < ::Dnet::SugarStruct
        layout( :ptr,       :uint8,
                :oflw_flg,  :uint8,
                :iptspairs, :uint32 )

      end

      # (Loose Source/Record/Strict Source) Route option data - RFC 791, 3.1
      #
      #   struct ip_opt_data_rr {
      #     uint8_t    ptr;    /* from start of option, >= 4 */
      #     uint32_t  iplist __flexarr; /* list of IP addresses */
      #   } __attribute__((__packed__));
      #
      class DataRR < ::Dnet::SugarStruct
        layout( :ptr,     :uint8,
                :iplist,  :uint32 )

      end

      #  Traceroute option data - RFC 1393, 2.2
      #
      #   struct ip_opt_data_tr {
      #     uint16_t  id;     /* ID number */
      #     uint16_t  ohc;    /* outbound hop count */
      #     uint16_t  rhc;    /* return hop count */
      #     uint32_t  origip; /* originator IP address */
      #   } __attribute__((__packed__));
      #
      class DataTR < ::Dnet::SugarStruct
        layout( :id,      :uint16,
                :ohc,     :uint16,
                :rhc,     :uint16,
                :origip,  :uint32 )

      end

    end # class Opt


    # Abstraction around dnet(3)'s ip_t handle for transmitting raw IP packets
    # routed by the kernel.
    class Handle < ::Dnet::Handle

      # Obtains a handle to transmit raw IP packets, routed by the kernel.
      # Uses dnet(3)'s ip_open() function under the hood.
      def initialize
        if (@handle=::Dnet.ip_open).address == 0
          raise H_ERR.new("unable to open IP raw packet handle")
        end
        _handle_opened!
      end

      # Transmits len bytes of the IP packet 'buf'. Len can be left
      # blank for String objects, which will use the size of the string.
      def ip_send(buf, len=nil)
        pbuf, sz = ::Dnet::Util.derive_pointer(buf, len)
        ::Dnet.ip_send(@handle, pbuf, sz)
      end

      # closes the IP raw packet handle
      def close
        _do_if_open { _handle_closed!; ::Dnet.ip_close(@handle) }
      end

      # Transmits len bytes of the IP packet pointed to by buf through a
      # temporary Ip::Handle which is closed immediately after sending.
      # 
      # See also Ip::Handle#ip_send
      def self.ip_send(buf, len=nil)
        open {|h| h.ip_send(buf, len)}
      end

      # Instance alias to ::Dnet.ip_add_option()
      def add_option(*args);  ::Dnet::Ip.ip_add_option(*args); end

      # Instance alias to ::Dnet.ip_checksum()
      def checksum(*args);    ::Dnet::Ip.ip_checksum(*args);  end

    end # class Handle


    # Adds the header option for the protocol proto specified
    # by 'optbuf' of length 'osz' and appends it to the appropriate header of
    # the IP packet contained in 'buf' of size 'bsz', shifting any existing 
    # payload and adding NOPs to pad the option to a word boundary if necessary.
    #
    # The buf and/or optbuf can be String or FFI::Pointer objects. Pointers 
    # must also include the associated size in bsz or osz respectively.
    #
    # sizes are required for buffer
    #
    #     ssize_t ip_add_option(void *buf, size_t len, int proto, 
    #             const void *optbuf, size_t optlen);
    def self.add_option(buf, proto, optbuf, bsz = nil, osz = nil)
      bufp, blen = ::Dnet::Util.derive_pointer(buf, bsz)
      optbufp, olen = ::Dnet::Util.derive_pointer(optbuf, osz)
      ::Dnet.ip_add_option(bufp, proto, blen, optbufp, olen)
    end

    # Sets the IP checksum and any appropriate transport protocol
    # checksum for the IP packet pointed to by buf of length len
    #
    # returns [buf-pointer, buf-length]
    #
    #     void ip_checksum(void *buf, size_t len);
    def self.checksum(buf, len=nil)
      bufp, plen = ::Dnet::Util.derive_pointer(buf, len)
      ::Dnet.ip_checksum bufp, plen
      return [bufp, plen]
    end
    

  end # module Ip

  # Alias for Ip::Handle
  class IpHandle < Ip::Handle;  end

  attach_function :ip_open, [], :ip_t
  attach_function :ip_add_option, [ :pointer, :size_t, :int, :pointer, 
    :size_t ], :ssize_t
  attach_function :ip_checksum, [:pointer, :size_t], :void
  attach_function :ip_send, [:ip_t, :pointer, :size_t], :ssize_t
  attach_function :ip_close, [:ip_t], :ip_t

end

