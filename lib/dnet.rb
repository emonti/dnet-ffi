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
require 'dnet/ethernet'
require 'dnet/arp'
require 'dnet/ip'
require 'dnet/ip6'
require 'dnet/tcp.rb'
require 'dnet/interface'
require 'dnet/route'
require 'dnet/fw'
require 'dnet/tun'
require 'dnet/blob'
require 'dnet/rand'

