
### libdnet's IP interface

module Dnet

  module Ip
    # Protocols (proto) - http://www.iana.org/assignments/protocol-numbers
    #
    # Contains mappings for all the IP_PROTO_[A-Z].* constants 
    # (defined in constants.rb)
    module Proto
      include ::FFI::DRY::ConstMap
      slurp_constants(::Dnet, "IP_PROTO_")
      def self.list;  @@list ||= super(); end
    end

    # IP header, without options
    #
    #   field :v_hl,    :uint8,   :desc => 'v=vers(. & 0xf0) / '+
    #                                      'hl=hdr len(. & 0x0f)'
    #   field :tos,     :uint8,   :desc => 'type of service'
    #   field :len,     :uint16,  :desc => 'total length (incl header)'
    #   field :id,      :uint16,  :desc => 'identification'
    #   field :off,     :uint16,  :desc => 'fragment offset and flags'
    #   field :ttl,     :uint8,   :desc => 'time to live'
    #   field :proto,   :uint8,   :desc => 'protocol'
    #   field :sum,     :uint16,  :desc => 'checksum'
    #   field :src,     :uint32,  :desc => 'source address'
    #   field :dst,     :uint32,  :desc => 'destination address'
    #
    class Hdr < ::FFI::Struct
      include ::FFI::DRY::StructHelper
      include ::Dnet::NetStructBE
    
      dsl_layout do
        field :v_hl,    :uint8,   :desc => 'v=vers(. & 0xf0) / '+
                                           'hl=hdr len(. & 0x0f)'
        field :tos,     :uint8,   :desc => 'type of service'
        field :len,     :uint16,  :desc => 'total length (incl header)'
        field :id,      :uint16,  :desc => 'identification'
        field :off,     :uint16,  :desc => 'fragment offset and flags'
        field :ttl,     :uint8,   :desc => 'time to live'
        field :proto,   :uint8,   :desc => 'protocol'
        field :sum,     :uint16,  :desc => 'checksum'
        field :src,     :uint32,  :desc => 'source address'
        field :dst,     :uint32,  :desc => 'destination address'
      end

      # Type of service (ip_tos), RFC 1349 ("obsoleted by RFC 2474")
      #
      # Contains mappings for all the IP_TOS_[A-Z].* constants
      module Tos
        include ::FFI::DRY::ConstMap
        slurp_constants(::Dnet, "IP_TOS_")
        def self.list;  @@list ||= super(); end
      end

      # Alias to ::Dnet::Ip::Proto
      Proto = ::Dnet::Ip::Proto

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
    #   array :otype, :uint8,            :desc => 'option type'
    #   array :len,   :uint8,            :desc => 'option length >= IP_OPE_LEN'
    #   array :data, [:uint8, DATA_LEN], :desc => 'option message data '
    #
    class Opt < ::FFI::Struct
      include ::FFI::DRY::StructHelper
      include ::Dnet::NetStructBE

      DATA_LEN = IP_OPT_LEN_MAX - IP_OPT_LEN
    
      dsl_layout do
        field :otype, :uint8,   :desc => 'option type'
        field :len,   :uint8,   :desc => 'option length >= IP_OPE_LEN'
        array :data, [:uint8, DATA_LEN], :desc => 'option message data '
      end

      # Option types (otype) - http://www.iana.org/assignments/ip-parameters
      #
      # Contains mappings for all the IP_OTYPE_[A-Z].* constants
      module Otype
        include ::FFI::DRY::ConstMap
        slurp_constants(::Dnet, "IP_OTYPE_")
        def self.list;  @@list ||= super(); end
      end

      # Security option data - RFC 791, 3.1
      #
      #   field :sec,   :uint16,     :desc => 'security'
      #   field :cpt,   :uint16,     :desc => 'compartments'
      #   field :hr,    :uint16,     :desc => 'handling restrictions'
      #   array :tcc,   [:uint8, 3], :desc => 'transmission control code'
      #
      class DataSEC < ::FFI::Struct
        include ::FFI::DRY::StructHelper
        include ::Dnet::NetStructBE
 
        dsl_layout do
          field :sec,   :uint16,     :desc => 'security'
          field :cpt,   :uint16,     :desc => 'compartments'
          field :hr,    :uint16,     :desc => 'handling restrictions'
          array :tcc,   [:uint8, 3], :desc => 'transmission control code'
        end

      end

      # Timestamp option data - RFC 791, 3.1
      #
      #   field :ptr,       :uint8,  :desc => 'from start of option'
      #   field :oflw_flg,  :uint8,  :desc => 'oflw = number of IPs skipped /'+
      #                                       'flg  = address/timestamp flag'
      #   field :iptspairs, :uint32, :desc => 'ip addr/ts pairs, var-length'
      #
      class DataTS < ::FFI::Struct
        include ::FFI::DRY::StructHelper
        include ::Dnet::NetStructBE 
        dsl_layout do
          field :ptr,       :uint8,  :desc => 'from start of option'
          field :oflw_flg,  :uint8,  :desc => 'oflw = number of IPs skipped /'+
                                              'flg  = address/timestamp flag'
          field :iptspairs, :uint32, :desc => 'ip addr/ts pairs, var-length'
        end

      end

      # (Loose Source/Record/Strict Source) Route option data - RFC 791, 3.1
      #
      #   field :ptr,     :uint8,   :desc => 'from start of option'
      #   field :iplist,  :uint32,  :desc => 'var-length list of IPs'
      #
      class DataRR < ::FFI::Struct
        include ::FFI::DRY::StructHelper
        include ::Dnet::NetStructBE
      
        dsl_layout do
          field :ptr,     :uint8,   :desc => 'from start of option'
          field :iplist,  :uint32,  :desc => 'var-length list of IPs'
        end

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
      class DataTR < ::FFI::Struct
        include ::FFI::DRY::StructHelper
        include ::Dnet::NetStructBE
      
        dsl_layout do
          field :id,      :uint16, :desc => 'ID number'
          field :ohc,     :uint16, :desc => 'outbound hop count'
          field :rhc,     :uint16, :desc => 'return hop count'
          field :origip,  :uint32, :desc => 'originator IP address'
        end
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
  IpHandle = Ip::Handle

  attach_function :ip_open, [], :ip_t
  attach_function :ip_add_option, [ :pointer, :size_t, :int, :pointer, 
    :size_t ], :ssize_t
  attach_function :ip_checksum, [:pointer, :size_t], :void
  attach_function :ip_send, [:ip_t, :pointer, :size_t], :ssize_t
  attach_function :ip_close, [:ip_t], :ip_t

end

