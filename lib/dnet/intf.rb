

module Dnet

  # Bindings and interface to dnet(3)'s api for network interfaces
  module Intf

    # An interface table entry
    #
    #   field  :len,       :uint,        :desc => 'length of entry'
    #   array  :if_name,   [:uint8, INTF_NAME_LEN], :desc => 'interface name'
    #   field  :itype,     :ushort,      :desc => 'interface type'
    #   field  :flags,     :ushort,      :desc => 'interface flags'
    #   field  :mtu,       :uint,        :desc => 'interface MTU'
    #   struct :if_addr,   ::Dnet::Addr, :desc => 'interface address'
    #   struct :dst_addr,  ::Dnet::Addr, :desc => 'point-to-point dst'
    #   struct :link_addr, ::Dnet::Addr, :desc => 'link-layer address'
    #   field  :alias_num, :uint,        :desc => 'number of aliases'
    #   #  :if_aliases,  ::Dnet::Addr  ) ## variable-length array of aliases
    #
    class Entry < ::FFI::Struct
      include ::FFI::DRY::StructHelper
    
      dsl_layout do
        field  :len,       :uint,        :desc => 'length of entry'
        array  :if_name,   [:uint8, INTF_NAME_LEN], :desc => 'interface name'
        field  :itype,     :ushort,      :desc => 'interface type'
        field  :flags,     :ushort,      :desc => 'interface flags'
        field  :mtu,       :uint,        :desc => 'interface MTU'
        struct :if_addr,   ::Dnet::Addr, :desc => 'interface address'
        struct :dst_addr,  ::Dnet::Addr, :desc => 'point-to-point dst'
        struct :link_addr, ::Dnet::Addr, :desc => 'link-layer address'
        field  :alias_num, :uint,        :desc => 'number of aliases'
        #  :if_aliases,  ::Dnet::Addr  ) ## variable-length array of aliases
      end

      # Constants map for interface flags. This is a map of flags, so
      # lookups for integers using [nnn] return a list of flags present in nnn.
      # Lookups for names using ["XX"], ["xx"] or [:xx] still return the value 
      # of the constant named XX.
      module Flags
        include ::FFI::DRY::ConstFlagsMap
        slurp_constants(::Dnet, "INTF_FLAG_")
        def self.list; @@list ||= super();  end
      end

      def lookup_flags; Flags[self[:flags]]; end

      # Constants map for interface types
      module Itype
        include ::FFI::DRY::ConstMap
        slurp_constants(::Dnet, "INTF_TYPE_")
        def self.list; @@list ||= super();  end
      end

      def lookup_itype; Flags[self[:itype]]; end

      # Returns a newly instantiated and allocated copy of this interface entry
      def copy
        xtra = (::Dnet::Addr.size * self.alias_num)
        if self.len == (Entry.size + xtra)
          super(xtra)
        else
          super()
        end
      end

      # returns an array containing all the aliases for this interface
      def aliases
        ary = []
        asz = ::Dnet::Addr.size
        p = (self.to_ptr() + Entry.size)  # start at end of struct
        self[:alias_num].times do 
          ary << ::Dnet::Addr.new(p)
          p += asz  
        end
        return ary
      end

      # returns the interface name string of this object
      def if_name;  self[:if_name].to_ptr.read_string; end

      # sets the interface name string on this object.
      def if_name=(val)
        name = ::Dnet.truncate_cstr(val, INTF_NAME_LEN)
        self[:if_name].to_ptr.write_string_length(name.to_s, len)
      end
      alias set_name if_name=

    end # class Entry

    # A handle to the network interface configuration.
    # This class manages a dnet(3) intf_t handle through intf_open() and
    # intf_close() and wraps several libdnet functions as ruby methods.
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
        _loop ::Dnet, :intf_loop, Entry, &block
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
        ie.if_name = name.to_s
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

      # Retrieves the configuration for the best interface with which to reach
      # the specified destination.
      #
      # int intf_get_dst(intf_t *i, struct intf_entry *entry, struct addr *dst);
      def get_dst(addr, ie=nil)
        _check_open!
        dst = Addr.new(addr.to_s)
        ie ||= Entry.new
        return ie if ::Dnet.intf_get_dst(@handle, ie, dst) == 0
      end

      # Sets the interface configuration entry. Usually requires 'root'
      # privileges.
      #
      # int intf_set(intf_t *i, const struct intf_entry *entry);
      def set(entry)
        _check_open!
        return true if ::Dnet.intf_set(@handle, entry) == 0
      end

    end # Handle

    def self.open(*args)
      Handle.open(*args) {|*y| yield(*y) if block_given? }
    end

    def self.each_entry(*args)
      Intf::Handle.each_entry(*args){|*y| yield(*y) }
    end

    def self.entries
      Intf::Handle.entries
    end

  end # Intf

  # Alias for Intf::Handle
  IntfHandle = Intf::Handle


  callback :intf_handler, [Intf::Entry, :ulong] , :int

  attach_function :intf_open, [], :intf_t
  attach_function :intf_get, [:intf_t, Intf::Entry], :int
  attach_function :intf_get_src, [:intf_t, Intf::Entry, Addr], :int
  attach_function :intf_get_dst, [:intf_t, Intf::Entry, Addr], :int
  attach_function :intf_set, [:intf_t, Intf::Entry], :int
  attach_function :intf_loop, [:intf_t, :intf_handler, :ulong], :int
  attach_function :intf_close, [:intf_t], :intf_t

end

