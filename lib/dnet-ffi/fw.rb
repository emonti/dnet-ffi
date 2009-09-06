
### dnet(3)'s firewalling interface

module Dnet

  #  struct fw_rule {
  #          char            fw_device[INTF_NAME_LEN]; /* interface name */
  #          uint8_t         fw_op;                    /* operation */
  #          uint8_t         fw_dir;                   /* direction */
  #          uint8_t         fw_proto;                 /* IP protocol */
  #          struct addr     fw_src;                   /* src address / net */
  #          struct addr     fw_dst;                   /* dst address / net */
  #          uint16_t        fw_sport[2];              /* range / ICMP type */
  #          uint16_t        fw_dport[2];              /* range / ICMP code */
  #  };
  class FwRule < FFI::Struct
    layout( :device,  [:char, INTF_NAME_LEN], # interface name
            :op,      :uchar,                 # operation
            :dir,     :uchar,                 # direction
            :proto,   :uchar,                 # IP protocol
            :src,     ::Dnet::Addr,           # src address / net
            :dst,     ::Dnet::Addr,           # dst address / net
            :sport,   [:ushort, 2],           # src port-range / ICMP type
            :dport,   [:ushort, 2] )          # dst port-range / ICMP code

    def device; self[:device].to_ptr.read_string ; end
    def op;     self[:op] ; end
    def dir;    self[:dir] ; end
    def proto;  self[:proto] ; end
    def src;    self[:src] ; end
    def dst;    self[:src] ; end
    def sport;  self[:sport].to_a ; end
    def dport;  self[:dport].to_a ; end
  end

  # FwHandle is used to obtain a handle to access the local network firewall 
  # configuration.
  class FwHandle < LoopableHandle

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
    # block with each rule cast as a FwRule object.  Uses dnet(3)'s fw_loop() 
    # function under the hood.
    def loop &block
      _loop :fw_loop, FwRule, &block
    end

    # Adds the specified FwRule entry to the ruleset. Uses dnet(3)'s 
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

  typedef :pointer, :fw_t
  callback :fw_handler, [:fw_t, :ulong], :int
  attach_function :fw_open, [], :fw_t
  attach_function :fw_add, [:fw_t, FwRule], :int
  attach_function :fw_delete, [:fw_t, FwRule], :int
  attach_function :fw_loop, [:fw_t, :fw_handler, :ulong], :int
  attach_function :fw_close, [:fw_t], :fw_t

end
