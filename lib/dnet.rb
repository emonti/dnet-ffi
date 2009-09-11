begin
  require 'rubygems'
rescue LoadError
end
require 'ffi'

module Dnet
  extend FFI::Library
  ffi_lib 'dnet'
end

require 'dnet/typedefs.rb'
require 'dnet/constants.rb' unless defined?(Dnet::DNET_CONSTANTS)

require 'dnet/util.rb'
require 'dnet/helpers.rb'

require 'dnet/addr'
require 'dnet/eth'
require 'dnet/arp'
require 'dnet/ip'
require 'dnet/ip6'
require 'dnet/icmp'
require 'dnet/tcp.rb'
require 'dnet/intf'
require 'dnet/route'
require 'dnet/fw'
require 'dnet/tun'
require 'dnet/blob'
require 'dnet/rand'

