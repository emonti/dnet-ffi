# Network addressing

module Dnet

  # FFI mapping to libdnet's 'addr' network address structure.
  #
  # libdnet's network addresses are described by the following C structure:
  #
  #    struct addr {
  #            uint16_t                addr_type;
  #            uint16_t                addr_bits;
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
  #    #define addr_eth        __addr_u.__eth
  #    #define addr_ip         __addr_u.__ip
  #    #define addr_ip6        __addr_u.__ip6
  #    #define addr_data8      __addr_u.__data8
  #    #define addr_data16     __addr_u.__data16
  #    #define addr_data32     __addr_u.__data32
  #
  # The following values are defined for addr_type:
  #
  #    #define ADDR_TYPE_NONE          0       /* No address set */
  #    #define ADDR_TYPE_ETH           1       /* Ethernet */
  #    #define ADDR_TYPE_IP            2       /* Internet Protocol v4 */
  #    #define ADDR_TYPE_IP6           3       /* Internet Protocol v6 */
  #
  # The field addr_bits denotes the length of the network mask in bits.
  #
  class Addr < FFI::Struct
    TYPE_NONE = 0
    TYPE_ETH  = 1
    TYPE_IP   = 2
    TYPE_IP6  = 3

    ADDR_TYPES = [ nil, :eth, :ip, :ip6 ]

    # struct addr { ... };
    # TODO put that addr_u union back in!!!!
    layout( :addr_type, :uint16,
            :addr_bits, :uint16,
            :addr,      [:uchar, 16])


    # Returns a human-readable network address from self. Uses libdnet's
    # addr_ntoa function under the hood.
    #
    # addr_ntoa converts an address from network format to a string, return-
    # ing a pointer to the result in static memory.
    #
    #   char * addr_ntoa(const struct addr *a);
    #
    def ntoa
      Dnet.addr_ntoa(self)
    end
    alias string ntoa
    alias addr ntoa

    def addr_type
      ADDR_TYPES[ self[:addr_type] ]
    end

    def addr_bits
      self[:addr_bits]
    end

    # Returns a new Addr object containing the broadcast address for the
    # network specified in this object. Uses libdnet's addr_bcast under the
    # hood.
    #
    # addr_bcast computes the broadcast address for the network specified in
    # a and writes it into b.
    #
    #   int addr_bcast(const struct addr *a, struct addr *b);
    def bcast
      bcast = self.class.new()
      Dnet.addr_bcast(self, bcast)
      return bcast
    end
    alias broadcast bcast

    # Returns a new Addr object containing the network address for the 
    # network specified in this object. Uses libdnet's addr_net under the
    # hood.
    #
    # addr_net computes the network address for the network specified in a
    # and writes it into b.
    #
    #   int addr_net(const struct addr *a, struct addr *b);
    def net
      n = self.class.new()
      Dnet.addr_net(self, n)
      return n
    end
    alias network net

    # Compare one Addr object against another. Uses libdnet's addr_cmp 
    # under the hood.
    #
    # addr_cmp compares network addresses a and b, returning an integer less
    # than, equal to, or greater than zero if a is found, respectively, to be
    # less than, equal to, or greater than b.  Both addresses must be of the
    # same address type.
    #
    #   int addr_cmp(const struct addr *a, const struct addr *b);
    #
    def <=>(other)
      Dnet.addr_cmp(self, other)
    end


    # Converts an address (or hostname) from a string to network format 
    # storing the result in this object. Uses libdnet's addr_pton under 
    # the hood.
    #
    #   int addr_pton(const char *src, struct addr *dst);
    #
    def from_string(str)
      return self if Dnet.addr_pton(str, self) == 0
    end
    alias pton from_string

    # Convert an address from network format to a string and store the 
    # result in a destination buffer.  This uses libdnet's addr_ntop under 
    # the hood.
    #
    #   char * addr_ntop(const struct addr *src, char *dst, size_t size);
    #
    def ntop(buf_p, sz)
      Dnet.addr_ntop(self, buf_p, sz)
    end

    # Returns a new Addr object from a string address. Hostnames work too.
    def self.from_string(str)
      new().from_string(str)
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

