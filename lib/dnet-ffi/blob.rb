
# A dnet blob_t structure.
module Dnet
  # blob_new is used to allocate a new dynamic binary buffer, returning
  # NULL on failure.
  #
  # Below is the libdnet C function definition:
  #
  #    blob_t * blob_new(void);
  #
  attach_function :blob_new, [], :pointer

  # blob_read reads len bytes from the current offset in blob b into buf,
  # returning the total number of bytes read, or -1 on failure.
  #
  # Below is the libdnet C function definition:
  #
  #    int blob_read(blob_t *b, void *buf, int len);
  #
  attach_function :blob_read, [:pointer, :pointer, :int], :int

  # blob_write writes len bytes from buf to blob b, advancing the current
  # offset. It returns the number of bytes written, or -1 on failure.
  #
  # Below is the libdnet C function definition:
  #
  #    int blob_write(blob_t *b, const void *buf, int len);
  #
  attach_function :blob_write, [:pointer, :pointer, :int], :int

  # blob_seek repositions the offset within blob b to off, according to the
  # directive whence (see lseek(2) for details), returning the new absolute
  # offset, or -1 on failure.
  # Below is the libdnet C function definition
  #
  #    int blob_seek(blob_t *b, int off, int whence);
  #
  attach_function :blob_seek, [:pointer, :int, :int], :int

  # blob_index returns the offset of the first occurence in blob b of the
  # specified buf of length len, or -1 on failure.
  #
  # Below is the libdnet C function definition
  #
  #    int blob_index(blob_t *b, const void *buf, int len);
  #
  attach_function :blob_index, [:pointer, :string, :int], :int

  # blob_rindex returns the offset of the last occurence in blob b of the
  # specified buf of length len, or -1 on failure.
  #
  # Below is the libdnet C function definition
  #
  #    int blob_rindex(blob_t *b, const void *buf, int len);
  #
  attach_function :blob_rindex, [:pointer, :string, :int], :int

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
  # blob_register_pack, currently undocumented.
  #
  # Below is the libdnet C function definition:
  #
  #    int blob_pack(blob_t *b, const void *fmt, ...);
  #
  attach_function :blob_pack, [:pointer, :string, :varargs], :int

  # See blob_pack
  #
  # Below is the libdnet C function definition:
  #
  #    int blob_unpack(blob_t *b, const void *fmt, ...);
  #
  attach_function :blob_unpack, [:pointer, :string, :varargs], :int

  # blob_print prints len bytes of the contents of blob b from the current
  # offset in the specified style; currently only ``hexl'' is available.
  #
  # int blob_print(blob_t *b, char *style, int len);
  #
  attach_function :blob_print, [:pointer, :string, :int], :int


  # blob_free deallocates the memory associated with blob b and returns
  # NULL.
  #
  # Below is the libdnet C function definition
  #
  #    blob_t * blob_free(blob_t *b);
  #
  attach_function :blob_free, [:pointer], :pointer


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

    def initialize(ptr=nil)
      ptr ||= Dnet.blob_new
      super(ptr)
    end

    def self.release(ptr)
      Dnet.blob_free(ptr)
    end

    def pack(fmt, *args)
      Dnet.blob_pack(self, fmt, *args)
    end

    def unpack(fmt, *args)
      Dnet.blob_unpack(self, fmt, *args)
    end

    def write(bstr)
      buf = ::FFI::MemoryPointer.from_string(bstr)
      buf.autorelease=true
      Dnet.blob_write(self, buf, bstr.size)
    end

    def read(len)
      buf = ::FFI::MemoryPointer.from_string("\x00"*len)
      buf.autorelease=true
      if Dnet.blob_read(self, buf, len) == 
        buf.read_string_length(len)
      else
        nil
      end
    end

  end
end

