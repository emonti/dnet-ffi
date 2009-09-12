# Here's where various BSD sockets typedefs and structures go
# ... good to have around

require 'socket'

module Dnet
  typedef :uint8, :sa_family_t
  typedef :uint32, :in_addr_t
  typedef :uint16, :in_port_t

  # contains AF_* constants culled from Ruby's ::Socket
  module AF
    include ConstMap
    slurp_constants(::Socket, "AF_")
    def self.list; @@list ||= super() ; end
  end

  class SockAddrFamily < SugarStruct
    def lookup_family
      ::Dnet::AF[ self[:family] ]
    end
  end

  # sockaddr, always good to have around
  class SockAddr < SockAddrFamily
    layout( :len,      :uint8,        # total length of struct
            :family,   :sa_family_t,  # AF_* (values may differ by platform)
            :data,     :char )        # variable length by :sa_len
  end


  class InAddr < SockAddrFamily
    layout( :s_addr,  :in_addr_t )
  end

  # sockaddr, always good to have around
  class SockAddrIn < SockAddrFamily
    layout( :len,      :uint8,         # length of structure(16)
            :family,  :sa_family_t,   # AF_INET
            :port,     :in_port_t,     # 16-bit TCP or UDP port number
            :addr,     :in_addr_t,     # 32-bit IPv4 address
            :_sa_zero,  [:char, 8] )    # unused
  end

  class In6Addr < SockAddrFamily
    layout( :s6_addr, [:uint, 16])
  end

  class SockAddrIn6 < SockAddrFamily
    layout( :len,        :uint8,       # length of structure(24))
            :family,     :sa_family_t, # AF_INET6
            :port,       :in_port_t,   # transport layer port#
            :flowinfo,   :uint32,      # priority & flow label
            :addr,       In6Addr )   # IPv6 address
  end

  class SockAddrDl < SockAddrFamily
    layout( :len,       :uint8,       # length of structure(variable)
            :family,    :sa_family_t, # AF_LINK
            :sdl_index, :uint16,      # system assigned index, if > 0
            :dltype,    :uint8,       # IFT_ETHER, etc. from net/if_types.h
            :nlen,      :uint8,       # name length, starting in sdl_data[0]
            :alen,      :uint8,       # link-layer addres-length
            :slen,      :uint8,       # link-layer selector length
            :_data,     :char )       # minimum work area=12, can be larger
  end

end
