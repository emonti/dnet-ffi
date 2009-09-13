# Address resolution Protocol

module Dnet
  module Arp
    # ARP header
    # 
    #   field :hrd, :uint16, :desc => 'format of hardware address'
    #   field :pro, :uint16, :desc => 'format of protocol address'
    #   field :hln, :uint16, :desc => 'length of hw address (ETH_ADDR_LEN)'
    #   field :pln, :uint16, :desc => 'length of proto address (IP_ADDR_LEN)'
    #   field :op,  :uint16, :desc => 'operation'
    class Hdr < ::FFI::Struct
      include ::FFI::DRY::StructHelper
      
      dsl_layout do
        field :hrd, :uint16, :desc => 'format of hardware address'
        field :pro, :uint16, :desc => 'format of protocol address'
        field :hln, :uint16, :desc => 'length of hw address (ETH_ADDR_LEN)'
        field :pln, :uint16, :desc => 'length of proto address (IP_ADDR_LEN)'
        field :op,  :uint16, :desc => 'operation'
      end

      # ARP operations
      module Op
        ::Dnet.constants.grep(/^(ARP_OP_([A-Z][A-Z0-9_]+))$/) do
          self.const_set $2, ::Dnet.const_get($1)
        end

        module_function
        def list
          @@list ||= constants.inject({}){|h,c| h.merge! c => const_get(c) }
        end
      end # Op
    end # Hdr

    # Ethernet/IP ARP message
    #
    #   array :sha, [:uint8, ETH_ADDR_LEN], :desc => 'sender hardware address'
    #   array :spa, [:uint8, IP_ADDR_LEN],  :desc => 'sender protocol address'
    #   array :tha, [:uint8, ETH_ADDR_LEN], :desc => 'target hardware address'
    #   array :tpa, [:uint8, IP_ADDR_LEN],  :desc => 'target protocol address'
    #
    class Ethip < ::FFI::Struct
      include ::FFI::DRY::StructHelper

      dsl_layout do
        array :sha, [:uint8, ETH_ADDR_LEN], :desc => 'sender hardware address'
        array :spa, [:uint8, IP_ADDR_LEN],  :desc => 'sender protocol address'
        array :tha, [:uint8, ETH_ADDR_LEN], :desc => 'target hardware address'
        array :tpa, [:uint8, IP_ADDR_LEN],  :desc => 'target protocol address'
      end

    end # Ethip

    
    # FFI mapping to libdnet's "arp_entry" struct.
    #
    # dnet(3)'s ARP cache entries are described by the following C structure:
    # 
    #   struct  :pa,  ::Dnet::Addr, :desc => 'protocol address'
    #   struct  :ha,  ::Dnet::Addr, :desc => 'hardware address'
    #
    class Entry < ::FFI::Struct
      include ::FFI::DRY::StructHelper

      dsl_layout do
        struct  :pa,  ::Dnet::Addr, :desc => 'protocol address'
        struct  :ha,  ::Dnet::Addr, :desc => 'hardware address'
      end

    end # Entry

    # A handle for accessing the kernel arp(4) cache. This does not require
    # root privileges.
    class Handle < LoopableHandle

      # Obtains a handle to access the kernel arp(4) cache. Uses dnet(3)'s 
      # arp_open() function under the hood.
      def initialize
        if (@handle = ::Dnet.arp_open).address == 0
          raise H_ERR.new("unable to open arp handle")
        end
        _handle_opened!
      end
      
      # Closes the handle. Uses dnet(3)'s arp_close() function under the hood.
      def close
        _do_if_open { _handle_closed!; ::Dnet.arp_close(@handle) }
      end

      # Iterates over the kernel arp cache, yielding each entry (cast as an
      # Entry) to a block. Uses dnet(3)'s arp_loop() function under the hood.
      def loop &block
        _loop ::Dnet, :arp_loop, Entry, &block
      end

      # Retrieves the ARP entry for the protocol address specified by 'addr'
      # (supplied as a String). Uses dnet(3)'s addr_aton() function to parse
      # 'addr' and arp_get() to retrieve a result, which is cast as an Entry 
      # instance.
      def get(addr)
        _check_open!
        ae = Entry.new
        return ae if ae.pa.set_string(addr) and 
                     ::Dnet.arp_get(@handle, ae) == 0
      end

      # Adds a new ARP entry specified as an Entry object. Uses dnet(3)'s 
      # arp_add() function under the hood.
      def add(entry)
        _check_open!
        ::Dnet.arp_add(@handle, entry)
      end

      # Deletes the ARP entry for the protocol address specified by
      # 'entry' supplied as an Entry object. Uses dnet(3)'s arp_delete()
      # function under the hood.
      def delete(entry)
        _check_open!
        ::Dnet.arp_delete(@handle, entry)
      end

    end # Handle

    # #define arp_pack_hdr_ethip(hdr, op, sha, spa, tha, tpa) do { \
    #   struct arp_hdr *pack_arp_p = (struct arp_hdr *)(hdr); \
    #   struct arp_ethip *pack_ethip_p = (struct arp_ethip *) \
    #     ((uint8_t *)(hdr) + ARP_HDR_LEN); \
    #   pack_arp_p->ar_hrd = htons(ARP_HRD_ETH); \
    #   pack_arp_p->ar_pro = htons(ARP_PRO_IP); \
    #   pack_arp_p->ar_hln = ETH_ADDR_LEN; \
    #   pack_arp_p->ar_pln = IP_ADDR_LEN; \
    #   pack_arp_p->ar_op = htons(op); \
    #   memmove(pack_ethip_p->ar_sha, &(sha), ETH_ADDR_LEN); \
    #   memmove(pack_ethip_p->ar_spa, &(spa), IP_ADDR_LEN); \
    #   memmove(pack_ethip_p->ar_tha, &(tha), ETH_ADDR_LEN); \
    #   memmove(pack_ethip_p->ar_tpa, &(tpa), IP_ADDR_LEN); \
    # } while (0)

    def self.open(*args)
      Handle.open(*args) {|*y| yield(*y) if block_given? }
    end

    def self.each_entry(*args)
      Handle.each_entry(*args) {|*y| yield(*y) }
    end

    def self.entries(*args)
      Handle.entries(*args)
    end

  end # Arp

  # This is just an alias for Arp::Handle
  ArpHandle = Arp::Handle

  typedef :pointer, :arp_t
  callback :arp_handler, [Arp::Entry, :ulong], :int
  attach_function :arp_open, [], :arp_t
  attach_function :arp_add, [:arp_t, Arp::Entry], :int
  attach_function :arp_delete, [:arp_t, Arp::Entry], :int
  attach_function :arp_get, [:arp_t, Arp::Entry], :int
  attach_function :arp_loop, [:arp_t, :arp_handler, :ulong], :int
  attach_function :arp_close, [:arp_t], :arp_t

end
