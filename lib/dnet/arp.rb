# Address resolution Protocol

module Dnet
  module Arp
    # ARP header
    # 
    #   struct arp_hdr {
    #     uint16_t  hrd;  /* format of hardware address */
    #     uint16_t  pro;  /* format of protocol address */
    #     uint8_t   hln;  /* length of hardware address (ETH_ADDR_LEN) */
    #     uint8_t   pln;  /* length of protocol address (IP_ADDR_LEN) */
    #     uint16_t  op;  /* operation */
    #   };
    class Hdr < ::Dnet::SugarStruct
      layout( :pro,   :uint16,
              :hrd,   :uint16,
              :hln,   :uint8,
              :pln,   :uint8,
              :op,    :uint16 )

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
    #   struct arp_ethip {
    #     uint8_t    ar_sha[ETH_ADDR_LEN];  /* sender hardware address */
    #     uint8_t    ar_spa[IP_ADDR_LEN];  /* sender protocol address */
    #     uint8_t    ar_tha[ETH_ADDR_LEN];  /* target hardware address */
    #     uint8_t    ar_tpa[IP_ADDR_LEN];  /* target protocol address */
    #   };
    class Ethip < ::Dnet::SugarStruct
      layout( :sha,   [:uint8, ETH_ADDR_LEN],
              :spa,   [:uint8, IP_ADDR_LEN],
              :tha,   [:uint8, ETH_ADDR_LEN],
              :tpa,   [:uint8, IP_ADDR_LEN] )

    end # Ethip

    
    # FFI mapping to libdnet's "arp_entry" struct.
    #
    # dnet(3)'s ARP cache entries are described by the following C structure:
    # 
    #   struct arp_entry {
    #          struct addr     pa;         /* protocol address */
    #          struct addr     ha;         /* hardware address */
    #   };
    #
    class Entry < ::Dnet::SugarStruct

      # struct arp_entry { ... };
      layout( :pa, ::Dnet::Addr,   # protocol address
              :ha, ::Dnet::Addr )  # hardware address

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
        _loop :arp_loop, Entry, &block
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

  end # Arp

  # This is just an alias for Arp::Handle
  class ArpHandle < Arp::Handle; end

  typedef :pointer, :arp_t
  callback :arp_handler, [Arp::Entry, :ulong], :int
  attach_function :arp_open, [], :arp_t
  attach_function :arp_add, [:arp_t, Arp::Entry], :int
  attach_function :arp_delete, [:arp_t, Arp::Entry], :int
  attach_function :arp_get, [:arp_t, Arp::Entry], :int
  attach_function :arp_loop, [:arp_t, :arp_handler, :ulong], :int
  attach_function :arp_close, [:arp_t], :arp_t

end
