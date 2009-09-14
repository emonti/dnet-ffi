
## blob is dnet(3)'s name for binary buffers

module Dnet

  # FFI mapping to dnet(3)'s "blob_t" binary buffer struct.
  #
  #   field :base, :pointer, :desc => 'start of data'
  #   field :off,  :pointer, :desc => 'offset into data'
  #   field :end,  :pointer, :desc => 'end of data'
  #   field :size, :pointer, :desc => 'size of allocation'
  #
  class Blob < FFI::ManagedStruct
    include ::FFI::DRY::StructHelper
    include HandleHelpers

    dsl_layout do
      field :base, :pointer, :desc => 'start of data'
      field :off,  :int,     :desc => 'offset into data'
      field :end,  :int,     :desc => 'end of data'
      field :size, :int,     :desc => 'size of allocation'
    end

    # Initializes a new Blob using dnet(3)'s blob_new under the hood.
    #
    # blob_new is used to allocate a new dynamic binary buffer, returning
    # NULL on failure.
    #
    # Below is the dnet(3) C function definition:
    #
    #    blob_t * blob_new(void);
    #
    def initialize
      super(::Dnet.blob_new())
      _handle_opened!
    end

    # Called by the garbage collector for ::FFI:ManagedStruct objects
    def self.release(blob)
      blob.release()
    end

    def base_ptr
      self[:base]
    end

    def curr_ptr
      safe[:base] + self[:off]
    end

    def end_ptr
      self[:base] + self[:end]
    end

    # This method calls dnet(3)'s blob_free behind the scenes. It should 
    # automatically get run by the garbage collector when a blob is no longer
    # referenced.
    # 
    # blob_free deallocates the memory associated with blob b and returns NULL.
    def release
      _do_if_open { _handle_closed! ; ::Dnet.blob_free(self) }
    end

    # blob_pack converts and writes, and blob_unpack() reads and converts data
    # in blob b according to the given format fmt as described below, returning
    # 0 on success, and -1 on failure.
    #
    # The format string is composed of zero or more directives: ordinary 
    # characters (not % ), which are copied to / read from the blob, and 
    # conversion specifications, each of which results in reading / writing 
    # zero or more subsequent arguments.
    #
    # Each conversion specification is introduced by the character %, and may
    # be prefixed by length specifier. The arguments must correspond properly
    # (after type promotion) with the length and conversion specifiers.
    #
    # The length specifier is either a a decimal digit string specifying the
    # length of the following argument, or the literal character * indicating
    # that the length should be read from an integer argument for the argument
    # following it.
    #
    # The conversion specifiers and their meanings are:
    #
    #     D       An unsigned 32-bit integer in network byte order.
    #     H       An unsigned 16-bit integer in network byte order.
    #     b       A binary buffer (length specifier required).
    #     c       An unsigned character.
    #     d       An unsigned 32-bit integer in host byte order.
    #     h       An unsigned 16-bit integer in host byte order.
    #     s       A C-style null-terminated string, whose maximum length must be
    #             specified when unpacking.
    #
    # Custom conversion routines and their specifiers may be registered via
    # blob_register_pack, currently undocumented. 
    #
    # TODO add ruby wrapper for blob_register_pack.
    #
    # XXX want to wrap varargs FFI for easier type casting?
    def pack(sfmt, *args)
      _check_open!
      (fmt = ::FFI::MemoryPointer.from_string(sfmt)).autorelease=true
      ::Dnet.blob_pack(self, fmt, *args)
    end

    # Uses dnet(3)s 'blob_unpack' under the hood.  See pack() for more 
    # information.
    #
    # XXX TODO - want to wrap varargs FFI for easier type casting?
    def unpack(sfmt, *args)
      _check_open!
      (fmt = ::FFI::MemoryPointer.from_string(sfmt)).autorelease=true
      ::Dnet.blob_unpack(self, fmt, *args)
    end

    # Writes the data supplied from a string or pointer to the blob at the 
    # current offset. If a pointer is supplied, a size must accompany it.
    # Uses dnet(3)'s "blob_write" under the hood.
    def write(buf, bsz=nil)
      _check_open!
      ptr, psz = ::Dnet::Util.derive_pointer(buf, bsz)
      ::Dnet.blob_write(self, ptr, psz)
    end

    # Reads 'len' bytes out of the blob from the current offset. If len is nil
    # (the default) then all remaining bytes are read. Moves the offset 
    # accordingly. This method uses dnet(3)'s "blob_read" under the hood.
    def read(len=nil)
      _check_open!
      len ||= self[:end] - self[:off]
      (buf = ::FFI::MemoryPointer.new("\x00", len)).autorelease = true
      if rlen=::Dnet.blob_read(self, buf, len)
        return buf.read_string_length(rlen)
      else
        nil
      end
    end

    # Returns the entirety of the blob from beginning to end.
    # Note, this will also move the offset to the end of the buffer.
    def string()
      _check_open!
      rewind()
      read()
    end

    # rewinds the blob buffer offset to the beginning
    def rewind
      _check_open!
      ::Dnet.blob_seek(self, 0, 0)
    end

    # sets the blob buffer offset to p. returns -1 on failure
    def pos=(p)
      _check_open!
      ::Dnet.blob_seek(self, p.to_i, 0)
    end

    # base pointer - start of data
    def base; 
      _check_open!
      self[:base]
    end

    # size of allocated data - aka self[:size]
    def blob_size; 
      _check_open!
      self[:size]
    end

    # returns the current position offset of the blob buffer - aka self[:off]
    def pos
      _check_open!
      self[:off]
    end

    # returns the end of the blob buffer in use - aka self[:end]
    def blob_end
      _check_open!
      self[:end]
    end

    # This method calls dnet(3)'s blob_seek under the hood.
    #
    # blob_seek repositions the offset within blob b to off, according to the
    # directive whence (see lseek(2) for details), returning the new absolute
    # offset, or -1 on failure.
    def seek(off, whence=0)
      _check_open!
      ::Dnet.blob_seek(self, off.to_i, whence.to_i)
    end

    # Uses dnet(3)'s "blob_index" under the hood. An additional 'rewind' 
    # argument was added which can be used to force a rewind before searching.
    # The default value for "rewind" is "false". nil is returned on a failed
    # search.
    def index(bstr, rewind=false)
      _check_open!
      self.rewind() if rewind
      (buf = ::FFI::MemoryPointer.from_string(bstr)).autorelease=true
      if (i=::Dnet.blob_index(self, buf, bstr.size)) > -1
        return i
      else
        return nil
      end
    end

    # Uses dnet(3)'s "blob_rindex" under the hood. An additional 'rewind' 
    # argument was added which can be used to force a rewind before searching.
    # The default value for "rewind" is "false". nil is returned on a failed
    # search.
    def rindex(buf, rewind=false)
      _check_open!
      self.rewind() if rewind
      (buf = ::FFI::MemoryPointer.from_string(bstr)).autorelease=true
      if (i=::Dnet.blob_rindex(self, buf, bstr.size)) > -1
        return i
      else
        return nil
      end
    end

    # Prints a hexdump on standard output using dnet(3)'s "blob_print" under 
    # the hood.  Can optionally rewind the blob before dumping using the 
    # 'rewind' argument (default: rewind=true).
    #
    # NOTE: len does not appear to do anything at all for blob_print
    def print_dump(rewind=true, len=nil)
      _check_open!
      self.rewind if rewind==true
      len ||= self[:end] - self[:off]
      Dnet.blob_print(self, "hexl", len.to_i)
    end
  end

  attach_function :blob_new,    [], :pointer
  attach_function :blob_read,   [Blob, :pointer, :int], :int
  attach_function :blob_write,  [Blob, :pointer, :int], :int
  attach_function :blob_seek,   [Blob, :int, :int], :int
  attach_function :blob_index,  [Blob, :pointer, :int], :int
  attach_function :blob_rindex, [Blob, :string, :int], :int
  attach_function :blob_pack,   [Blob, :string, :varargs], :int
  attach_function :blob_unpack, [Blob, :string, :varargs], :int
  attach_function :blob_print,  [Blob, :string, :int], :int
  attach_function :blob_free,   [Blob], :pointer
end

