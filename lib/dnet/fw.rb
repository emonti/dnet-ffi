
### dnet(3)'s firewalling interface

module Dnet

  module Fw
    #
    #   array  :device,  [:uint8, INTF_NAME_LEN], :desc => 'interface name'
    #   field  :op,      :uint8,        :desc => 'operation'
    #   field  :dir,     :uint8,        :desc => 'direction'
    #   field  :proto,   :uint8,        :desc => 'IP protocol'
    #   struct :src,     ::Dnet::Addr,  :desc => 'src address / net'
    #   struct :dst,     ::Dnet::Addr,  :desc => 'dst address / net'
    #   array  :sport,   [:uint16, 2],  :desc => 'src port-range / ICMP type'
    #   array  :dport,   [:uint16, 2],  :desc => 'dst port-range / ICMP code'
    #
    class Rule < ::FFI::Struct
      include ::FFI::DRY::StructHelper
      
      dsl_layout do
        array  :device,  [:uint8, INTF_NAME_LEN], :desc => 'interface name'
        field  :op,      :uint8,        :desc => 'operation'
        field  :dir,     :uint8,        :desc => 'direction'
        field  :proto,   :uint8,        :desc => 'IP protocol'
        struct :src,     ::Dnet::Addr,  :desc => 'src address / net'
        struct :dst,     ::Dnet::Addr,  :desc => 'dst address / net'
        array  :sport,   [:uint16, 2],  :desc => 'src port-range / ICMP type'
        array  :dport,   [:uint16, 2],  :desc => 'dst port-range / ICMP code'
      end

      # Alias to ::Dnet::Ip::Proto
      Proto = ::Dnet::Ip::Proto

      module Op 
        include ::FFI::DRY::ConstFlagsMap
        ALLOW = 1
        BLOCK = 2
        def self.list ; @@list ||= super(); end
      end

      module Dir
        include ::FFI::DRY::ConstFlagsMap
        IN  = 1
        OUT = 2
        def self.list ; @@list ||= super(); end
      end

      def device; self[:device].to_ptr.read_string ; end

      def device=(val)
        dev = ::Dnet.truncate_cstr(val.to_s, INTF_NAME_LEN)
        self[:device].to_ptr.write_string(dev, dev.size)
      end
    end

    # Fw::Handle is used to obtain a handle to access the local network 
    # firewall configuration.
    class Handle < ::Dnet::LoopableHandle

      # Uses dnet(3)'s fw_open() function under the hood.
      def initialize
        if (@handle = Dnet.fw_open()).address == 0
          raise H_ERR.new("unable to open fw handle")
        end
        _handle_opened!
      end

      # Closes the firewall handle. Uses dnet(3)'s fw_close() under the hood.
      def close
        _do_if_open { _handle_closed! ; Dnet.fw_close(@handle) }
      end

      # Iterates over the active firewall ruleset, invoking the specified 
      # block with each rule cast as a Rule object.  Uses dnet(3)'s fw_loop() 
      # function under the hood.
      def loop &block
        _loop ::Dnet, :fw_loop, Rule, &block
      end

      # Adds the specified Rule entry to the ruleset. Uses dnet(3)'s 
      # fw_add() function under the hood.
      def add(fw_rule)
        Dnet.fw_add @handle, fw_rule
      end

      # Deletes the specified firewall rule. Uses dnet(3)'s fw_delete() function
      # under the hood.
      def delete(fw_rule)
        Dnet.fw_delete @handle, fw_rule
      end
    end

    # an alias for Fw::Handle
    FwHandle = Fw::Handle

  end

  callback :fw_handler, [Fw::Rule, :ulong], :int

  attach_function :fw_open, [], :fw_t
  attach_function :fw_add, [:fw_t, Fw::Rule], :int
  attach_function :fw_delete, [:fw_t, Fw::Rule], :int
  attach_function :fw_loop, [:fw_t, :fw_handler, :ulong], :int
  attach_function :fw_close, [:fw_t], :fw_t

end
