begin
  require 'rubygems'
rescue LoadError
end
require 'ffi'

module Dnet
  extend FFI::Library
  ffi_lib 'dnet'
end

require 'dnet_ffi/version'
require 'dnet_ffi/ffi'

# structure classes
require 'dnet_ffi/addr'
require 'dnet_ffi/arp'
require 'dnet_ffi/blob'
require 'dnet_ffi/ethernet'
require 'dnet_ffi/fw'
require 'dnet_ffi/interface'
require 'dnet_ffi/ip'
require 'dnet_ffi/rand'
require 'dnet_ffi/route'
require 'dnet_ffi/tun'


