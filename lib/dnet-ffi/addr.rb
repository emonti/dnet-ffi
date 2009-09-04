# Network addressing

module Dnet

  # int addr_cmp(const struct addr *a, const struct addr *b);
  #
  #  addr_cmp compares network addresses a and b, returning an integer less
  #  than, equal to, or greater than zero if a is found, respectively, to be
  #  less than, equal to, or greater than b.  Both addresses must be of the
  #  same address type
  attach_function :addr_cmp, [:pointer, :pointer], :int

  # int addr_bcast(const struct addr *a, struct addr *b);
  #
  #  addr_bcast computes the broadcast address for the network specified in
  #  a and writes it into b.
  attach_function :addr_bcast, [:pointer, :pointer], :int

  # int addr_net(const struct addr *a, struct addr *b);
  #
  #  addr_net computes the network address for the network specified in a
  #  and writes it into b.
  attach_function :addr_net, [:pointer, :pointer], :int

  # char * addr_ntop(const struct addr *src, char *dst, size_t size);
  #
  #  addr_ntop converts an address from network format to a string.
  attach_function :addr_ntop, [:pointer, :string, :size_t], :string

  # int addr_pton(const char *src, struct addr *dst);
  #
  #  addr_pton converts an address (or hostname) from a string to network
  #  format.
  attach_function :addr_pton, [:string, :pointer], :int

  # addr_aton is just an alias for addr_pton
  class <<self ; alias_method :addr_aton, :addr_pton; end

  # char * addr_ntoa(const struct addr *a);
  #
  #  addr_ntoa converts an address from network format to a string, return-
  #  ing a pointer to the result in static memory.
  attach_function :addr_ntoa, [:pointer], :string

  # int addr_ntos(const struct addr *a, struct sockaddr *sa);
  #
  #  addr_ntos converts an address from network format to the appropriate
  #  struct sockaddr.
  attach_function :addr_ntos, [:pointer, :pointer], :int

  # int addr_ston(const struct sockaddr *sa, struct addr *a);
  #
  #  addr_ston converts an address from a struct sockaddr to network format.
  attach_function :addr_ston, [:pointer, :pointer], :int

  # int addr_btos(uint16_t bits, struct sockaddr *sa);
  #
  #  addr_btos converts a network mask length to a network mask specified as
  #  a struct sockaddr.
  attach_function :addr_btos, [:uint16, :pointer], :int

  # int addr_stob(const struct sockaddr *sa, uint16_t *bits);
  #  addr_stob converts a network mask specified in a struct sockaddr to a
  #  network mask length.
  attach_function :addr_stob, [:pointer, :pointer], :int

  # int addr_btom(uint16_t bits, void *mask, size_t size);
  #
  #  addr_btom converts a network mask length to a network mask in network
  #  byte order.
  attach_function :addr_btom, [:uint16, :string, :size_t], :int

  # int addr_mtob(const void *mask, size_t size, uint16_t *bits);
  #
  #  addr_mtob converts a network mask in network byte order to a network
  #  mask length.
  attach_function :addr_mtob, [:string, :size_t, :uint16], :int


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

    # FFI mapping to libdnet's '__addr_u' union which is a member of the 'addr'
    # structure definition.
    #
    # See Addr class for more info.
    class Addr_U < FFI::Union
      # union { ... } __addr_u;
      layout( :eth,    [:uchar, 6],  # Dnet::Addr::TYPE_ETH
              :ip,     [:uchar, 4],  # Dnet::Addr::TYPE_IP
              :ip6,    [:uchar, 8],  # Dnet::Addr::TYPE_IP6

              :data8,  [:uchar, 16],
              :data16, [:ushort, 8],
              :data32, [:ulong, 4] )
    end

    # struct addr { ... };
    layout( :addr_type, :uint16,
            :addr_bits, :uint16,
            :addr,      Addr_U )

  end

end

