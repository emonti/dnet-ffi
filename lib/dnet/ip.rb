
### libdnet's IP interface

module Dnet

  module Ip

    include FFI::Packets::Ip

    # Abstraction around dnet(3)'s ip_t handle for transmitting raw IP packets
    # routed by the kernel.
    class Handle < ::Dnet::Handle

      # Obtains a handle to transmit raw IP packets, routed by the kernel.
      # Uses dnet(3)'s ip_open() function under the hood.
      def initialize
        if (@handle=::Dnet.ip_open).address == 0
          raise H_ERR.new("unable to open IP raw packet handle")
        end
        _handle_opened!
      end

      # Transmits len bytes of the IP packet 'buf'. Len can be left
      # blank for String objects, which will use the size of the string.
      def ip_send(buf, len=nil)
        pbuf, sz = ::Dnet::Util.derive_pointer(buf, len)
        ::Dnet.ip_send(@handle, pbuf, sz)
      end

      # closes the IP raw packet handle
      def close
        _do_if_open { _handle_closed!; ::Dnet.ip_close(@handle) }
      end

      # Transmits len bytes of the IP packet pointed to by buf through a
      # temporary Ip::Handle which is closed immediately after sending.
      # 
      # See also Ip::Handle#ip_send
      def self.ip_send(buf, len=nil)
        open {|h| h.ip_send(buf, len)}
      end

      # Instance alias to ::Dnet.ip_add_option()
      def add_option(*args);  ::Dnet::Ip.ip_add_option(*args); end

      # Instance alias to ::Dnet.ip_checksum()
      def checksum(*args);    ::Dnet::Ip.ip_checksum(*args);  end

    end # class Handle


    # Adds the header option for the protocol proto specified
    # by 'optbuf' of length 'osz' and appends it to the appropriate header of
    # the IP packet contained in 'buf' of size 'bsz', shifting any existing 
    # payload and adding NOPs to pad the option to a word boundary if necessary.
    #
    # The buf and/or optbuf can be String or FFI::Pointer objects. Pointers 
    # must also include the associated size in bsz or osz respectively.
    #
    # sizes are required for buffer
    #
    #     ssize_t ip_add_option(void *buf, size_t len, int proto, 
    #             const void *optbuf, size_t optlen);
    def self.add_option(buf, proto, optbuf, bsz = nil, osz = nil)
      bufp, blen = ::Dnet::Util.derive_pointer(buf, bsz)
      optbufp, olen = ::Dnet::Util.derive_pointer(optbuf, osz)
      ::Dnet.ip_add_option(bufp, proto, blen, optbufp, olen)
    end

    # Sets the IP checksum and any appropriate transport protocol
    # checksum for the IP packet pointed to by buf of length len
    #
    # returns [buf-pointer, buf-length]
    #
    #     void ip_checksum(void *buf, size_t len);
    def self.checksum(buf, len=nil)
      bufp, plen = ::Dnet::Util.derive_pointer(buf, len)
      ::Dnet.ip_checksum bufp, plen
      return [bufp, plen]
    end
    

  end # module Ip

  # Alias for Ip::Handle
  IpHandle = Ip::Handle

  attach_function :ip_open, [], :ip_t
  attach_function :ip_add_option, [:pointer, :size_t, :int, :pointer, :size_t], :ssize_t
  attach_function :ip_checksum, [:pointer, :size_t], :void
  attach_function :ip_send, [:ip_t, :pointer, :size_t], :ssize_t
  attach_function :ip_close, [:ip_t], :ip_t

end

