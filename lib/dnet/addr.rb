# Network addressing

module Dnet

  # FFI mapping to dnet(3)'s 'addr' network address structure.
  #
  # dnet(3)'s network addresses are described by the following C structure:
  #
  #    struct addr {
  #            uint16_t                atype;
  #            uint16_t                abits;
  #            union {
  #                    eth_addr_t      __eth;
  #                    ip_addr_t       __ip;
  #                    ip6_addr_t      __ip6;
  #
  #                    uint8_t         __data8[16];
  #                    uint16_t        __data16[8];
  #                    uint32_t        __data32[4];
  #            } __addr_u;
  #    };
  #
  class Addr < ::FFI::Struct
    include ::FFI::DRY::StructHelper

    ADDR_TYPES = [ nil, :eth, :ip, :ip6 ] # A mapping of dnet address types

    # struct addr { ... };
    dsl_layout do
      field :atype, :uint16
      field :bits,  :uint16
      array :addr,  [:uchar, 16]
    end

    # If passed a String argument (and only 1 arg), it will be parsed as 
    # an address using set_string(). 
    #
    # The fields :bits and :addr aren't allowed to be used together.
    # Instead, just use :addr => 'n.n.n.n/bits'. See also set_string()
    def initialize(*args)
      if args.size == 1 and (str=args[0]).is_a? String
        super()
        self.aton(str)
      else
        super(*args)
      end
    end

    # Overrides set_fields to reject :bits fields when :addr is supplied as 
    # well.
    #
    # Forces you to use :addr => 'x.x.x.x/nn' instead. Having both together
    # leaves setting :bits up to chance depending on which hash key gets
    # plucked first in set_fields() because of how ip_aton() works under 
    # the hood.
    def set_fields(params)
      if params[:bits] and params[:addr]
        raise( ::ArgumentError, 
           "Don't use :addr and :bits fields together. "+
           "Just use :addr => 'x.x.x.x/nn' where nn are the bits." )
      else
        super(params)
      end
    end

    # Looks up this object's 'atype' member against ADDR_TYPES
    # Returns a symbol for the type or nil a type is not found.
    def addr_type; ADDR_TYPES[ self[:atype] ] ; end

    # Returns a human-readable network address from self. Uses dnet(3)'s
    # addr_ntoa function under the hood.
    def ntoa
      Dnet.addr_ntoa(self)
    end
    alias string ntoa
    alias addr ntoa

    # Returns a new Addr object containing the broadcast address for the
    # network specified in this object. Uses dnet(3)'s addr_bcast under the
    # hood.
    def bcast
      bcast = self.class.new()
      Dnet.addr_bcast(self, bcast)
      return bcast
    end
    alias broadcast bcast

    # Returns a new Addr object containing the network address for the 
    # network specified in this object. Uses dnet(3)'s addr_net under the
    # hood.
    def net
      n = self.class.new()
      Dnet.addr_net(self, n)
      return n
    end
    alias network net

    # Compare one Addr object against another. Uses dnet(3)'s addr_cmp 
    # under the hood.
    #
    # addr_cmp() compares network addresses a and b, returning an integer less
    # than, equal to, or greater than zero if a is found, respectively, to be
    # less than, equal to, or greater than b.  Both addresses must be of the
    # same address type.
    def <=>(other)
      raise "can only compare another #{self.class}" unless other.is_a? Addr
      Dnet.addr_cmp(self, other)
    end

    # Converts an address (or hostname) from a string to network format 
    # storing the result in this object. Uses dnet(3)'s addr_pton under 
    # the hood.
    def set_string(str)
      return self if Dnet.addr_pton(str, self) == 0
    end
    alias aton set_string
    alias pton set_string
    alias from_string set_string
    alias addr= set_string

    # Convert an address from network format to a string and store the 
    # result in a destination buffer.  This uses dnet(3)'s addr_ntop under 
    # the hood.
    def ntop(buf_p, sz)
      Dnet.addr_ntop(self, buf_p, sz)
    end

    # Returns a new Addr object from a string address. Hostnames work too.
    def self.from_string(str)
      new().set_string(str)
    end

    # Returns a new Addr object containing the broadcast address for the
    # given string address.
    def self.bcast(str)
      return nil unless b=from_string(str)
      b.bcast
    end

    # Returns a new Addr object containing the broadcast address for the
    # given string address.
    def self.net(str)
      return nil unless n=from_string(str)
      n.net
    end
  end

  attach_function :addr_cmp,    [Addr, Addr], :int
  attach_function :addr_bcast,  [Addr, Addr], :int
  attach_function :addr_net,    [Addr, Addr], :int
  attach_function :addr_ntop,   [Addr, :pointer, :size_t], :string
  attach_function :addr_ntoa,   [Addr], :string
  attach_function :addr_pton,   [:string, Addr], :int

  # addr_aton is just an alias for addr_pton. eh, it's in the manpage...
  class <<self ; alias_method :addr_aton, :addr_pton; end

  ### Misc unused stuff from dnet(3):

  # addr_ntos converts an address from network format to the appropriate
  # struct sockaddr.
  #
  #   int addr_ntos(const struct addr *a, struct sockaddr *sa);
  #
  attach_function :addr_ntos, [:pointer, :pointer], :int

  # addr_ston converts an address from a struct sockaddr to network format.
  #
  #   int addr_ston(const struct sockaddr *sa, struct addr *a);
  #
  attach_function :addr_ston, [:pointer, :pointer], :int

  # addr_btos converts a network mask length to a network mask specified as
  # a struct sockaddr.
  #
  #   int addr_btos(uint16_t bits, struct sockaddr *sa);
  #
  attach_function :addr_btos, [:uint16, :pointer], :int

  # addr_stob converts a network mask specified in a struct sockaddr to a
  # network mask length.
  #
  #   int addr_stob(const struct sockaddr *sa, uint16_t *bits);
  #
  attach_function :addr_stob, [:pointer, :pointer], :int

  # addr_btom converts a network mask length to a network mask in network
  # byte order.
  #
  #   int addr_btom(uint16_t bits, void *mask, size_t size);
  attach_function :addr_btom, [:uint16, :pointer, :size_t], :int

  # addr_mtob converts a network mask in network byte order to a network
  # mask length.
  #
  #   int addr_mtob(const void *mask, size_t size, uint16_t *bits);
  #
  attach_function :addr_mtob, [:pointer, :size_t, :uint16], :int

end

