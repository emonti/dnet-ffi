
### libdnet's api for network interfaces

module Dnet
  class IntfEntry < FFI::Struct
    layout( :if_len,         :uint,        # length of entry
            :if_name,        [:uint8, 16], # interface name
            :if_type,        :ushort,      # interface type
            :if_flags,       :ushort,      # interface flags
            :if_mtu,         :uint,        # interface MTU
            :if_addr,        Addr,         # interface address
            :if_dst_addr,    Addr,         # point-to-point dst
            :if_link_addr,   Addr,         # link-layer address
            :if_alias_num,   :uint,        # number of aliases
            :if_aliases,     :pointer  )   # array of aliases

    # length of entry
    def if_len;   self[:if_len]; end

    def if_len=(val)
      self[:if_len] = val.to_i
    end

    # interface name
    def if_name;  self[:if_name].to_ptr.read_string; end

    def set_name(name)
      name[15]="\x00" if name.size > 15
      len = name.size < 16 ? name.size : 16
      self[:if_name].to_ptr.write_string_length(name.to_s, len)
    end

    # interface type
    def if_type;  self[:if_type]; end

    # interface flags
    def if_flags; self[:if_flags]; end

    # interface mtu
    def if_mtu; self[:if_mtu]; end

    # interface address
    def if_addr;  self[:if_addr]; end

    # point-to-point destination
    def if_dst_addr; self[:if_dst_addr]; end

    # link-layer-address
    def if_link_addr; self[:if_link_addr]; end

    # number of aliases
    def if_alias_num;  self[:if_alias_num]; end

    def if_aliases
      # ...
    end

    def self.new_with_aliases(num)
      sz = IntfEntry.size + (num * Addr.size)
      ie = new( ::FFI::MemoryPointer.new("\x00", sz) )
      ie.if_len = sz
      return ie
    end
  end

  class IntfHandle < LoopableHandle

    # Obtains a handle to access the network interface configuration.
    def initialize
      if (@handle = ::Dnet.intf_open).address == 0
        raise H_ERR.new("unable to open interface handle")
      end
      _handle_opened!
    end

    # Closes the handle. Uses dnet(3)'s arp_close() function under the hood
    def close
      _do_if_open { _handle_closed!; ::Dnet.intf_close(@handle) }
    end

    # Iterates over all network interfaces, yielding each entry (cast as an
    # IntfEntry) to a block. Uses dnet(3)'s intf_loop() function under the
    # hood.
    def loop &block
      _loop :intf_loop, IntfEntry, &block
    end

    # intf_get() retrieves an interface configuration entry, keyed on
    # intf_name.  For all intf_get() functions, intf_len should be set to the
    # size of the buffer pointed to by entry (usually sizeof(struct
    # intf_entry), but should be larger to accomodate any interface alias
    # addresses.
    # 
    #   int intf_get(intf_t *i, struct intf_entry *entry);
    #
    def get(name, ie=nil)
      _check_open!
      ie ||= IntfEntry.new_with_aliases(0)
      ie.set_name(name.to_s)
      return ie if ::Dnet.intf_get(@handle, ie) == 0
    end

    # retrieves the configuration for the interface whose primary address 
    # matches the specified src.
    #
    # int intf_get_src(intf_t *i, struct intf_entry *entry, struct addr *src);
    def get_src(addr, ie=nil)
      _check_open!
      src = Addr.new(addr.to_s)
      ie ||= IntfEntry.new_with_aliases(0)
      return ie if ::Dnet.intf_get_src(@handle, ie, src) == 0
    end

    # retrieves the configuration for the best interface with which to reach
    # the specified destination.
    #
    # int intf_get_dst(intf_t *i, struct intf_entry *entry, struct addr *dst);
    def get_dst(addr, ie=nil)
      _check_open!
      dst = Addr.new(addr.to_s)
      ie ||= IntfEntry.new_with_aliases(0)
      return ie if ::Dnet.intf_get_dst(@handle, ie, dst) == 0
    end

    # int intf_set(intf_t *i, const struct intf_entry *entry);
    def set(entry)
      _check_open!
      return ie if ::Dnet.intf_set(entry) == 0
    end

  end

  typedef :pointer, :intf_t
  callback :intf_handler, [IntfEntry, :ulong] , :int
  attach_function :intf_open, [], :intf_t
  attach_function :intf_get, [:intf_t, IntfEntry], :int
  attach_function :intf_get_src, [:intf_t, IntfEntry, Addr], :int
  attach_function :intf_get_dst, [:intf_t, IntfEntry, Addr], :int
  attach_function :intf_set, [:intf_t, IntfEntry], :int
  attach_function :intf_loop, [:intf_t, :intf_handler, :ulong], :int
  attach_function :intf_close, [:intf_t], :intf_t

end
