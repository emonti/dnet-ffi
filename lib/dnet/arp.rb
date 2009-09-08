# Address resolution Protocol

module Dnet
  # FFI mapping to libdnet's "arp_entry" struct.
  #
  # libnet's ARP cache entries are described by the following C structure:
  # 
  #   struct arp_entry {
  #          struct addr     arp_pa;         /* protocol address */
  #          struct addr     arp_ha;         /* hardware address */
  #   };
  #
  # Helper methods and internal struct members map to the following names
  #
  # * arp_pa == paddr / self[:paddr]
  # * arp_ha == haddr / self[:haddr]
  #
  class ArpEntry < FFI::Struct

    # struct arp_entry { ... };
    layout( :paddr, ::Dnet::Addr,   # protocol address
            :haddr, ::Dnet::Addr )  # hardware address

    # protocol address
    def paddr ; self[:paddr] ; end

    # hardware address
    def haddr ; self[:haddr] ; end
  end

  class ArpHandle < LoopableHandle

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
    # ArpEntry) to a block. Uses dnet(3)'s arp_loop() function under the hood.
    def loop &block
      _loop :arp_loop, ArpEntry, &block
    end

    # Retrieves the ARP entry for the protocol address specified by 'addr'
    # (supplied as a String). Uses dnet(3)'s addr_aton() function to parse
    # 'addr' and arp_get() to retrieve a result, which is cast as an ArpEntry 
    # instance.
    def get(addr)
      _check_open!
      ae = ArpEntry.new
      return ae if ae.paddr.set_string(addr) and 
                   ::Dnet.arp_get(@handle, ae) == 0
    end

    # Adds a new ARP entry specified as an ArpEntry object. Uses dnet(3)'s 
    # arp_add() function under the hood.
    def add(entry)
      _check_open!
      ::Dnet.arp_add(@handle, entry)
    end

    # Deletes the ARP entry for the protocol address specified by
    # 'entry' supplied as an ArpEntry object. Uses dnet(3)'s arp_delete()
    # function under the hood.
    def delete(entry)
      _check_open!
      ::Dnet.arp_delete(@handle, entry)
    end

  end


  typedef :pointer, :arp_t
  callback :arp_handler, [ArpEntry, :ulong], :int
  attach_function :arp_open, [], :arp_t
  attach_function :arp_add, [:arp_t, ArpEntry], :int
  attach_function :arp_delete, [:arp_t, ArpEntry], :int
  attach_function :arp_get, [:arp_t, ArpEntry], :int
  attach_function :arp_loop, [:arp_t, :arp_handler, :ulong], :int
  attach_function :arp_close, [:arp_t], :arp_t

end
