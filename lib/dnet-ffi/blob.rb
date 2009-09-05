
# A dnet blob_t structure.
module Dnet

  # attach all the libdnet blob_* related functions ...

  attach_function :blob_new,    [], :pointer
  attach_function :blob_read,   [:pointer, :pointer, :int], :int
  attach_function :blob_write,  [:pointer, :pointer, :int], :int
  attach_function :blob_seek,   [:pointer, :int, :int], :int
  attach_function :blob_index,  [:pointer, :pointer, :int], :int
  attach_function :blob_rindex, [:pointer, :string, :int], :int
  attach_function :blob_pack,   [:pointer, :string, :varargs], :int
  attach_function :blob_unpack, [:pointer, :string, :varargs], :int
  attach_function :blob_print,  [:pointer, :string, :int], :int
  attach_function :blob_free,   [:pointer], :pointer


  # FFI mapping to libdnet's "blob_t" binary buffer struct.
  #
  # libdnet's binary buffers are described by the following C structure:
  #
  #    typedef struct blob {
  #            u_char          *base;          /* start of data */
  #            int              off;           /* offset into data */
  #            int              end;           /* end of data */
  #            int              size;          /* size of allocation */
  #    } blob_t;
  #
  class Blob < FFI::ManagedStruct
    # struct blob { ... } blob_t;
    layout( :base, :pointer,
            :off,  :int,
            :end,  :int,
            :size, :int )

    # Initializes a new Blob using libdnet's blob_new under the hood.
    #
    # blob_new is used to allocate a new dynamic binary buffer, returning
    # NULL on failure.
    #
    # Below is the libdnet C function definition:
    #
    #    blob_t * blob_new(void);
    #
    def initialize
      @blob_closed = false
      super(blob_new())
    end

    # Called by the garbage collector for ::FFI:ManagedStruct objects
    def self.release(blob)
      blob.release()
    end

    # A sanity check used throughout to make sure we don't accidentally
    # use this blob after it has been released
    def _check_closed
      raise "blob has already been released" if @blob_closed
    end

    # This method calls libdnet's blob_free behind the scenes. It should auto-
    # matically get run by the garbage collector when a blob is no longer
    # referenced. You probably don't want to use this method unless you
    # are sure about what you're doing
    # 
    # blob_free deallocates the memory associated with blob b and returns
    # NULL.
    #
    # Below is the libdnet C function definition
    #
    #    blob_t * blob_free(blob_t *b);
    #
    def release
      return nil if @blob_closed
      @blob_closed = true
      Dnet.blob_free(self)
    end

    # blob_pack converts and writes, and blob_unpack() reads and converts data
    # in blob b according to the given format fmt as described below, returning
    # 0 on success, and -1 on failure.
    #
    # The format string is composed of zero or more directives: ordinary char-
    # acters (not % ), which are copied to / read from the blob, and conversion
    # specifications, each of which results in reading / writing zero or more
    # subsequent arguments.
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
    # blob_register_pack, currently undocumented. TODO add ruby wrapper.
    #
    # Below is the libdnet C function definition:
    #
    #    int blob_pack(blob_t *b, const void *fmt, ...);
    #
    def pack(sfmt, *args)
      _check_closed
      (fmt = ::FFI::MemoryPointer.from_string(sfmt)).autorelease=true
      Dnet.blob_pack(self, fmt, *args)
    end

    # Uses libdnets 'blob_unpack' under the hood.  See pack for more 
    # information.
    #
    # Below is the libdnet C function definition:
    #
    #    int blob_unpack(blob_t *b, const void *fmt, ...);
    #
    def unpack(sfmt, *args)
      _check_closed
      (fmt = ::FFI::MemoryPointer.from_string(sfmt)).autorelease=true
      Dnet.blob_unpack(self, fmt, *args)
    end

    # Writes the supplied string to the blob at the current offset. Uses
    # libdnet's "blob_write" under the hood.
    #
    # blob_write writes len bytes from buf to blob b, advancing the current
    # offset. It returns the number of bytes written, or -1 on failure.
    #
    # Below is the libdnet C function definition:
    #
    #    int blob_write(blob_t *b, const void *buf, int len);
    #
    def write(bstr)
      _check_closed
      buf = ::FFI::MemoryPointer.from_string(bstr)
      buf.autorelease=true
      Dnet.blob_write(self, buf, bstr.size)
    end

    # Reads 'len' bytes out of the blob from the current offset. If len is nil
    # (the default) then all remaining bytes are read. Moves the offset 
    # accordingly. This method uses libdnet's "blob_read" under the hood.
    #
    # blob_read reads len bytes from the current offset in blob b into buf,
    # returning the total number of bytes read, or -1 on failure.
    #
    # Below is the libdnet C function definition:
    #
    #    int blob_read(blob_t *b, void *buf, int len);
    #
    def read(len=nil)
      _check_closed
      len ||= self[:end] - self[:off]
      buf = ::FFI::MemoryPointer.from_string("\x00"*len)
      buf.autorelease=true
      if rlen=Dnet.blob_read(self, buf, len)
        return buf.read_string_length(rlen)
      else
        nil
      end
    end

    # rewinds the blob buffer offset to the beginning
    def rewind
      _check_closed
      Dnet.blob_seek(self, 0, 0)
    end


    # sets the blob buffer offset to p
    def pos=(p)
      _check_closed
      raise "position must be positive" unless p > -1
      Dnet.blob_seek(self, p, 0) == p or raise "position out of bounds"
    end

    # returns the current position offset of the blob buffer
    def pos
      _check_closed
      self[:off]
    end

    # returns the end of the blob buffer in use
    def blob_end
      _check_closed
      self[:end]
    end

    # This method calls libdnet's blob_seek under the hood.
    #
    # blob_seek repositions the offset within blob b to off, according to the
    # directive whence (see lseek(2) for details), returning the new absolute
    # offset, or -1 on failure.
    # Below is the libdnet C function definition
    #
    #    int blob_seek(blob_t *b, int off, int whence);
    #
    def seek(off, whence=0)
      _check_closed
      Dnet.blob_seek(self, off, whence)
    end

    # Uses libdnet's "blob_index" under the hood. An additional 'rewind' 
    # argument was added which can be used to force a rewind before searching.
    # The default value for "rewind" is "false". nil is returned on a failed
    # search.
    #
    # blob_index returns the offset of the first occurence in blob b of the
    # specified buf of length len, or -1 on failure.
    #
    # Below is the libdnet C function definition
    #
    #    int blob_index(blob_t *b, const void *buf, int len);
    #
    def index(bstr, rewind=false)
      _check_closed
      self.rewind() if rewind
      buf = ::FFI::MemoryPointer.from_string(bstr)
      buf.autorelease=true
      if (i=Dnet.blob_index(self, buf, bstr.size)) > -1
        return i
      else
        return nil
      end
    end

    # Uses libdnet's "blob_rindex" under the hood. An additional 'rewind' 
    # argument was added which can be used to force a rewind before searching.
    # The default value for "rewind" is "false". nil is returned on a failed
    # search.
    #
    # blob_rindex returns the offset of the last occurence in blob b of the
    # specified buf of length len, or -1 on failure.
    #
    # Below is the libdnet C function definition
    #
    #    int blob_rindex(blob_t *b, const void *buf, int len);
    #
    def rindex(buf, rewind=false)
      _check_closed
      self.rewind() if rewind
      buf = ::FFI::MemoryPointer.from_string(bstr)
      buf.autorelease=true
      if (i=Dnet.blob_rindex(self, buf, bstr.size)) > -1
        return i
      else
        return nil
      end
    end

    # Prints a hexdump on standard output using libdnet's "blob_print" under 
    # the hood.  Can optionally rewind the blob before dumping using the 
    # 'rewind' argument (default: rewind=true).
    #
    # blob_print prints len bytes of the contents of blob b from the current
    # offset in the specified style; currently only ``hexl'' is available.
    #
    # NOTE: len does not appear to do anything at all
    #
    # int blob_print(blob_t *b, char *style, int len);
    #
    def print_dump(rewind=true, len=nil)
      _check_closed
      self.rewind if rewind==true
      len ||= self[:end] - self[:off]
      Dnet.blob_print(self, "hexl", len)
    end
  end
end

