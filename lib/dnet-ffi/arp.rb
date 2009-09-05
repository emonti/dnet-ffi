# Address resolution Protocol

module Dnet
  class ArpHandle
    def self.open
      a = new()
      return a unless block_given?
      begin
        ret = yield(a)
      ensure
        a.close
      end
      return ret
    end

    def self.each_entry
      open {|a| a.loop {|e| yield e } }
    end

    def self.entries
      ary = []
      each_entry {|x| ary << x}
      ary
    end

    def initialize
      @arp_closed = false
      @arp_t = Dnet.arp_open
    end
    
    def close
      return nil if @arp_closed
      @arp_closed = true
      Dnet.arp_close(@arp_t)
    end

    def loop
      b = lambda {|e, i| yield ArpEntry.new(e); nil }
      Dnet.arp_loop( @arp_t, b, self.object_id )
    end

    def get_entry(addr)
      ae = ArpEntry.new
      if( Dnet.addr_aton(addr.to_s, ae[:paddr]) == 0 and 
          Dnet.arp_get(@arp_t, ae) == 0 )
        return ae
      end
    end

    def add_entry(entry)
      Dnet.arp_add(@arp_t, entry)
    end

    def delete_entry(entry)
      Dnet.arp_delete(@arp_t, entry)
    end

  end

  # FFI mapping to libdnet's "arp_entry" struct.
  #
  # libnet's ARP cache entries are described by the following C structure:
  # 
  #   struct arp_entry {
  #          struct addr     arp_pa;         /* protocol address */
  #          struct addr     arp_ha;         /* hardware address */
  #   };
  #
  class ArpEntry < FFI::Struct

    # struct arp_entry { ... };
    layout( :paddr, ::Dnet::Addr,
            :haddr, ::Dnet::Addr )


    def paddr
      self[:paddr]
    end

    def haddr
      self[:haddr]
    end
  end

  # The callback definition used by arp_loop
  #   typedef int (*arp_handler)(const struct arp_entry *entry, void *arg);
  callback :arp_handler, [:pointer, :ulong], :int

  # arp_open is used to obtain a handle to access the kernel arp(4) cache.
  #
  #   arp_t * arp_open(void);
  attach_function :arp_open, [], :pointer

  # arp_add adds a new ARP entry.
  #
  #   int arp_add(arp_t *a, const struct arp_entry *entry);
  attach_function :arp_add, [:pointer, ArpEntry], :int

  # arp_delete deletes the ARP entry for the protocol address specified by
  # arp_pa.
  #
  #   int arp_delete(arp_t *a, const struct arp_entry *entry);
  attach_function :arp_delete, [:pointer, ArpEntry], :int

  # arp_get retrieves the ARP entry for the protocol address specified by
  # arp_pa.
  #
  #   int arp_get(arp_t *a, struct arp_entry *entry);
  attach_function :arp_get, [:pointer, ArpEntry], :int

  # arp_loop iterates over the kernel arp cache, invoking the specified
  # callback with each entry and the context arg passed to arp_loop.
  #
  #   int arp_loop(arp_t *a, arp_handler callback, void *arg);
  attach_function :arp_loop, [:pointer, :arp_handler, :ulong], :int

  # arp_close closes the specified handle.
  #
  #   arp_t * arp_close(arp_t *a);
  attach_function :arp_close, [:pointer], :pointer

end
