begin
  require 'rubygems'
rescue LoadError
end
require 'ffi'

module Dnet
  extend FFI::Library
  ffi_lib 'dnet'
end

require 'dnet-ffi/defs.rb' unless defined?(Dnet::DNET_DEFS)

require 'dnet-ffi/util.rb'
require 'dnet-ffi/helpers.rb'

require 'dnet-ffi/addr'
require 'dnet-ffi/ethernet'
require 'dnet-ffi/arp'
require 'dnet-ffi/ip'
require 'dnet-ffi/ip6'
require 'dnet-ffi/tcp.rb'
require 'dnet-ffi/interface'
require 'dnet-ffi/route'
require 'dnet-ffi/fw'
require 'dnet-ffi/tun'
require 'dnet-ffi/blob'
require 'dnet-ffi/rand'

