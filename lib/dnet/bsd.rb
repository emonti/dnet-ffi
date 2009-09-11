# Here's where various BSD sockets typedefs and structures go
# ... good to have around

require 'socket'

module Dnet
  typedef :uint8, :sa_family_t
  typedef :uint32, :in_addr_t
  typedef :uint16, :in_port_t

  # sockaddr, always good to have around
  class Sockaddr < ::Dnet::SugarStruct
    layout( :sa_len,      :uint8,        # total length of struct
            :sa_family,   :sa_family_t,  # AF_* (values may differ by platform)
            :sa_data,     :char )        # variable length by :sa_len
  end


  class InAddr < ::Dnet::SugarStruct
    layout( :s_addr,  :in_addr_t )
  end

  # sockaddr, always good to have around
  class SockAddrIn < ::Dnet::SugarStruct
    layout( :sa_len,      :uint8,         # length of structure(16)
            :sin_family,  :sa_family_t,   # AF_INET
            :sin_port,    :in_port_t,     # 16-bit TCP or UDP port number
            :sin_addr,    :in_addr_t,     # 32-bit IPv4 address
            :sa_zero,     [:char, 8] )    # unused
  end

  class In6Addr < ::Dnet::SugarStruct
    layout( :s6_addr, [:uint, 16])
  end

  class SockAddrIn6 < ::Dnet::SugarStruct
    layout( :sin6_len,        :uint8,       # length of structure(24))
            :sin6_family,     :sa_family_t, # AF_INET6
            :sin6_port,       :in_port_t,   # transport layer port#
            :sin6_flowinfo,   :uint32,      # priority & flow label
            :sin6_addr,       In6Addr )   # IPv6 address
  end

  class SockAddrDl < ::Dnet::SugarStruct
    layout( :sdl_len,     :uint8,       # length of structure(variable)
            :sdl_family,  :sa_family_t, # AF_LINK
            :sdl_index,   :uint16,      # system assigned index, if > 0
            :sdl_type,    :uint8,       # IFT_ETHER, etc. from net/if_types.h
            :sdl_nlen,    :uint8,       # name length, starting in sdl_data[0]
            :sdl_alen,    :uint8,       # link-layer addres-length
            :sdl_slen,    :uint8,       # link-layer selector length
            :sdl_data,    :char )       # minimum work area=12, can be larger
  end

  # contains AF_* constants culled from Ruby's ::Socket
  module AF
    include ConstMap
    slurp_constants(::Socket, "AF_")
    def self.list; @@list ||= super() ; end
  end

end
