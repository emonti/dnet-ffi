# Bindings for dnet(3)'s eth_* API

module Dnet

  MAC_RX = /^[a-f0-9]{1,2}([:-]?)(?:[a-f0-9]{1,2}\1){4}[a-f0-9]{1,2}$/i
  
  # FFI implementation of dnet(3)'s eth_addr struct.
  class EthAddr < FFI::Struct
    # struct eth_addr { ... } eth_addr_t;
    layout( :data, [:uchar, ETH_ADDR_LEN] )

    def initialize(*args)
      if args.size == 1 and (s=args[0]).is_a? String
        raise "bad mac address" unless s =~ MAC_RX
        raw = ::Dnet::Util.unhexify(s, /[:-]/)
        super(::FFI::MemoryPointer.from_string(raw))
      else
        super(*args)
      end
    end
    
    # Returns the MAC address raw data reference.
    def data; self[:data] ; end

    # Returns the MAC address as an array of unsigned char values.
    def chars; data.to_a ; end

    # Returns the MAC address as a string with colon-separated hex-bytes.
    def string; chars.map {|x| "%0.2x" % x }.join(':'); end
  end

  # dnet(3)'s dnet.h defines the following structure:
  #
  #   struct eth_hdr {
  #     eth_addr_t	eth_dst;	/* destination address */
  #     eth_addr_t	eth_src;	/* source address */
  #     uint16_t	eth_type;	/* payload type */
  #   };
  class EthHdr < FFI::Struct
    # struct eth_hdr { ... };
    layout( :eth_dst,   EthAddr,
            :eth_src,   EthAddr,
            :eth_type,  :ushort )

    # destination address
    def eth_dst;  self[:eth_dst]; end

    # source address
    def eth_src;  self[:eth_src]; end

    # payload type
    def eth_type; self[:eth_type]; end
  end


  # Obtains a new handle to transmit raw Ethernet frames via the specified
  # network device.
  #
  class EthHandle < Handle
    # Uses dnet(3)'s eth_open under the hood:
    def initialize(dev)
      @handle=Dnet.eth_open(dev.to_s)
      if @handle.address == 0
        raise H_ERR.new("Unable to open device: #{dev.inspect}") 
      end
      _handle_opened!
    end

    # Closes the handle. Uses dnet(3)'s eth_close() under the hood:
    def close
      _do_if_open { _handle_closed!; Dnet.eth_close(@handle) }
    end

    # Retrieves the hardware MAC address for this interface and returns it
    # as a EthAddr object. Uses dnet(3)'s eth_get() function under the hood.
    def macaddr()
      _check_open!
      ea = EthAddr.new
      return nil unless Dnet.eth_get(@handle, ea) == 0
      return ea
    end

    # Configures the hardware MAC address for this interface to the specified
    # address supplied as a string of colon-separated hex-bytes (example: 
    # "de:ad:be:ef:01"). Uses dnet(3)'s addr_aton() to parse ea_str and 
    # eth_set() to set the address under the hood.
    def macaddr=(ea_str)
      _check_open!
      if ( ea=EthAddr.new(ea_str.to_s) and Dnet.eth_set(@handle, ea) == 0 )
        return true
      end
    end

    # Transmits an ethernet frame (supplied as a String, sbuf). Uses dnet(3)'s 
    # eth_send() function under the hood.
    def eth_send(sbuf)
      _check_open!
      sbuf = sbuf.to_s
      (buf = ::FFI::MemoryPointer.from_string(sbuf)).autorelease = true
      Dnet.eth_send(@handle, buf, sbuf.size)
    end
  end

  typedef :pointer, :eth_t
  attach_function :eth_open, [:string], :eth_t
  attach_function :eth_get, [:eth_t, EthAddr ], :int
  attach_function :eth_set, [:eth_t, EthAddr], :int
  attach_function :eth_send, [:eth_t, :pointer, :size_t], :ssize_t
  attach_function :eth_close, [:eth_t], :eth_t

end