
module Dnet
  module Util
    include FFI::Library

    def self.unhexify(str, d=/\s*/)
      str.to_s.strip.gsub(/([A-Fa-f0-9]{1,2})#{d}?/) { $1.hex.chr }
    end

    # Attempts to derive a memroy pointer and length from an "anonymous" object.
    # Returns an an array object containing [len, pointer]
    #
    # buf can be a String or FFI::Pointer. If it is a Pointer, bsz must also
    # be supplied for the length. If bsz is included with a String, the string
    # will be truncated if it is longer.
    #
    # This is mostly used to support multiple argument types in various 
    # functions.
    def self.derive_pointer(buf, bsz=nil)
      case buf
      when ::FFI::Pointer
        raise "no length specified for the pointer" if bsz.nil?
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
    

    private

    # alias to class method
    def derive_mempointer(*args)
      ::Dnet::Util.derive_mempointer(*args)
    end

    # alias to class method
    def unhexify(*args)
      ::Dnet::Util.unhexify(*args)
    end
  end # Dnet::Util

  attach_function :htons, [:uint16], :uint16
  attach_function :ntohs, [:uint16], :uint16
  attach_function :htonl, [:uint32], :uint32
  attach_function :ntohl, [:uint32], :uint32
end
