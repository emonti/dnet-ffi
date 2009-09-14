
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
      include ::Dnet::NetEndianHelper
    
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

      # Overrides set_fields to supply a default value for the 'v_hl' field.
      #
      #   v  = 4
      #   hl = 5 # number of 32-bit words - 20 bytes (size of hdr without opts)
      #
      def set_fields(params=nil)
        params ||= {}
        super({:v_hl => 0x45}.merge(params))
      end

      # Sets the value of the hl field. This field is a 4-bit value occupying
      # the lower 4 bits of the 'v_hl' field.
      #
      # This value is the size of the IP header (including opts if present)
      # in 32-bit words. The byte size maximum is 15*4 - 60 bytes.
      def hl=(val)
        raise(ArgumentError, "value for header length too high") if val > 0xf
        self[:v_hl] &= 0xf0
        self[:v_hl] += val
      end

      # Returns the value of the hl field. This field is a 4-bit value occupying
      # the lower 4 bits of the 'v_hl' field.
      #
      # This value is the size of the IP header (including opts if present)
      # in 32-bit words. The byte size maximum is 15*4 - 60 bytes.
      def hl
        self[:v_hl] & 0x0f
      end

      # Type of service (ip_tos), RFC 1349 ("obsoleted by RFC 2474")
      #
      # Contains mappings for all the IP_TOS_[A-Z].* flags constants
      module Tos
        include ::FFI::DRY::ConstFlagsMap
        slurp_constants(::Dnet, "IP_TOS_")
        def self.list;  @@list ||= super(); end
      end

      def lookup_tos;  Tos[ self.tos ]; end

      # Alias to ::Dnet::Ip::Proto
      Proto = ::Dnet::Ip::Proto

      def lookup_proto; Proto[ self.proto ]; end

      # Sets source IP address in the header from an IPv4 address string or 
      # 32-bit number.
      def src=(val)
        val = ::Dnet::Util.ipv4_atol(val) if val.kind_of? String
        self[:src] = ::Dnet.htonl(val)
      end

      # Returns the source IP address as an IPv4 address string as an IPv4 
      # address string.
      def src
        ::Dnet::Util.ipv4_ltoa( ::Dnet.ntohl( self[:src] ))
      end

      # Sets destination IP address in the header from an IPv4 address string 
      # or 32-bit number.
      def dst=(val)
        val = ::Dnet::Util.ipv4_atol(val) if val.kind_of? String
        self[:dst] = ::Dnet.htonl(val)
      end

      # Returns the destination IP address from the header as an IPv4 address 
      # string.
      def dst
        ::Dnet::Util.ipv4_ltoa( ::Dnet.ntohl( self[:dst] ))
      end

    end # class Hdr


    # IP option (following IP header)
    #
    #   array :otype, :uint8,            :desc => 'option type'
    #   array :len,   :uint8,            :desc => 'option length >= IP_OPE_LEN'
    #   array :data, [:uint8, DATA_LEN], :desc => 'option message data '
    #
    class Opt < ::FFI::Struct
      include ::FFI::DRY::StructHelper
      include ::Dnet::NetEndianHelper

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
        include ::Dnet::NetEndianHelper
 
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
      #   field :iptspairs, :uint32, :desc => 'IP addr/ts pairs, var-length'
      #
      class DataTS < ::FFI::Struct
        include ::FFI::DRY::StructHelper
        include ::Dnet::NetEndianHelper 
        dsl_layout do
          field :ptr,       :uint8,  :desc => 'from start of option'
          field :oflw_flg,  :uint8,  :desc => 'oflw = number of IPs skipped /'+
                                              'flg  = address/timestamp flag'
          field :iptspairs, :uint32, :desc => 'IP addr/ts pairs, var-length'
        end

      end

      # (Loose Source/Record/Strict Source) Route option data - RFC 791, 3.1
      #
      #   field :ptr,     :uint8,   :desc => 'from start of option'
      #   field :iplist,  :uint32,  :desc => 'var-length list of IPs'
      #
      class DataRR < ::FFI::Struct
        include ::FFI::DRY::StructHelper
        include ::Dnet::NetEndianHelper
      
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
        include ::Dnet::NetEndianHelper
      
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
  attach_function :ip_add_option, [:pointer, :size_t, :int, :pointer, :size_t], :ssize_t
  attach_function :ip_checksum, [:pointer, :size_t], :void
  attach_function :ip_send, [:ip_t, :pointer, :size_t], :ssize_t
  attach_function :ip_close, [:ip_t], :ip_t

end

