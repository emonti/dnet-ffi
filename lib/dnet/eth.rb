# Bindings for dnet(3)'s eth_* API

module Dnet
  
  module Eth
    include FFI::Packets::Eth
    
    # Obtains a new handle to transmit raw Ethernet frames via the specified
    # network device.
    #
    class Handle < ::Dnet::Handle
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

    end # Handle

    def self.open(*args)
      Handle.open(*args){|*y| yield(*y) if block_given? }
    end

    def self.eth_send(dev, *args)
      Handle.open(dev){|h| h.eth_send(*args) }
    end
  end # Eth

  # This is just an alias for ::Dnet::Eth::EthAddr
  EthAddr = Eth::EthAddr

  # This is just an alias for ::Dnet::Eth::Handle
  EthHandle = Eth::Handle

  attach_function :eth_open, [:string], :eth_t
  attach_function :eth_get, [:eth_t, EthAddr], :int
  attach_function :eth_set, [:eth_t, EthAddr], :int
  attach_function :eth_send, [:eth_t, :pointer, :size_t], :ssize_t
  attach_function :eth_close, [:eth_t], :eth_t

end # Dnet
