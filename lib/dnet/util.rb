
module Dnet
  module Util
    RX_IP4_ADDR = /(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)/
    RX_MAC_ADDR = /(?:(?:[a-f0-9]{1,2}[:-])?{5}[a-f0-9]{1,2})/i

    # A number of helper methods which can be used to extend class, instance, 
    # or module
    module Helpers

      def unhexify(str, d=/\s*/)
        str.to_s.strip.gsub(/([A-Fa-f0-9]{1,2})#{d}?/) { $1.hex.chr }
      end

      # Attempts to derive a memory pointer and length from an "anonymous" object.
      # Returns an an array object containing [len, pointer]
      #
      # buf can be a String or FFI::Pointer. If it is a Pointer, bsz must also
      # be supplied for the length. If bsz is included with a String, the string
      # will be truncated if it is longer.
      #
      # This is mostly used to support multiple argument types in various 
      # functions.
      def derive_pointer(buf, bsz=nil)
        case buf
        when ::FFI::Pointer
          raise "no length specified for pointer" if bsz.nil?
          raise "size must be a number >= 0" unless bsz.is_a? Numeric and bsz >= 0
          raise "null pointer #{buf.inspect}" if buf.address == 0
          pbuf = buf
        when String
          buf = buf[0,bsz] if bsz
          pbuf = ::FFI::MemoryPointer.from_string(buf)
          bsz = buf.size
        else
          raise "cannot derive a pointer and size from a #{buf.class}"
        end
        return [pbuf, bsz]
      end
      
      # takes a IPv4 number and returns it as a 32-bit number
      def ipv4_atol(str)
        unless str =~ /^#{::Dnet::Util::RX_IP4_ADDR}$/
          raise(::ArgumentError, "invalid IP address #{str.inspect}")
        else
          u32=0
          str.split('.',4).each {|o| u32 = ((u32 << 8) | o.to_i) }
          return u32
        end
      end

      # takes a 32-bit number and returns it as an IPv4 address string.
      def ipv4_ltoa(int)
        unless(int.is_a? Numeric and int <= 0xffffffff)
          raise(::ArgumentError, "not a long integer: #{int.inspect}")
        end
        ret = []
        4.times do 
          ret.unshift(int & 0xff)
          int >>= 8
        end
        ret.join('.')
      end

    end # module Helpers

    extend(::Dnet::Util::Helpers)
  end # module Util

end
