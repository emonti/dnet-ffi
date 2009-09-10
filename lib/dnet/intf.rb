

module Dnet

  # Bindings and interface to dnet(3)'s api for network interfaces
  module Intf

    # An interface table entry
    class Entry < ::Dnet::SugarStruct
      layout( :if_len,         :uint,        # length of entry
              :if_name,        [:uint8, 16], # interface name
              :if_type,        :ushort,      # interface type
              :if_flags,       :ushort,      # interface flags
              :if_mtu,         :uint,        # interface MTU
              :if_addr,        ::Dnet::Addr, # interface address
              :if_dst_addr,    ::Dnet::Addr, # point-to-point dst
              :if_link_addr,   ::Dnet::Addr, # link-layer address
              :if_alias_num,   :uint )       # number of aliases
            #  :if_aliases,     ::Dnet::Addr  )   # array of aliases

      # interface name
      def if_name;  self[:if_name].to_ptr.read_string; end

      def set_name(val)
        name = ::Dnet.truncate_cstr(val, 16)
        self[:if_name].to_ptr.write_string_length(name.to_s, len)
      end
      alias if_name= set_name

    end

    class Handle < ::Dnet::LoopableHandle

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
      # Intf::Entry) to a block. Uses dnet(3)'s intf_loop() function under the
      # hood.
      def loop &block
        _loop :intf_loop, Entry, &block
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
        ie ||= Entry.new
        ie.name = name.to_s
        return ie if ::Dnet.intf_get(@handle, ie) == 0
      end

      # retrieves the configuration for the interface whose primary address 
      # matches the specified src.
      #
      # int intf_get_src(intf_t *i, struct intf_entry *entry, struct addr *src);
      def get_src(addr, ie=nil)
        _check_open!
        src = Addr.new(addr.to_s)
        ie ||= Entry.new
        return ie if ::Dnet.intf_get_src(@handle, ie, src) == 0
      end

      # retrieves the configuration for the best interface with which to reach
      # the specified destination.
      #
      # int intf_get_dst(intf_t *i, struct intf_entry *entry, struct addr *dst);
      def get_dst(addr, ie=nil)
        _check_open!
        dst = Addr.new(addr.to_s)
        ie ||= Entry.new
        return ie if ::Dnet.intf_get_dst(@handle, ie, dst) == 0
      end

      # int intf_set(intf_t *i, const struct intf_entry *entry);
      def set(entry)
        _check_open!
        return ie if ::Dnet.intf_set(entry) == 0
      end

    end # Handle
  end # Intf

  # Alias for Intf::Handle
  class IntfHandle < Intf::Handle ; end

  callback :intf_handler, [Intf::Entry, :ulong] , :int

  attach_function :intf_open, [], :intf_t
  attach_function :intf_get, [:intf_t, Intf::Entry], :int
  attach_function :intf_get_src, [:intf_t, Intf::Entry, Addr], :int
  attach_function :intf_get_dst, [:intf_t, Intf::Entry, Addr], :int
  attach_function :intf_set, [:intf_t, Intf::Entry], :int
  attach_function :intf_loop, [:intf_t, :intf_handler, :ulong], :int
  attach_function :intf_close, [:intf_t], :intf_t

end
