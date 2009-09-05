begin
  require 'rubygems'
rescue LoadError
end
require 'ffi'

module Dnet
  extend FFI::Library
  ffi_lib 'dnet'
end

require 'dnet-ffi/ffi'

# structure classes
require 'dnet-ffi/addr'
require 'dnet-ffi/arp'
require 'dnet-ffi/blob'
require 'dnet-ffi/ethernet'
require 'dnet-ffi/fw'
require 'dnet-ffi/interface'
require 'dnet-ffi/ip'
require 'dnet-ffi/rand'
require 'dnet-ffi/route'
require 'dnet-ffi/tun'


