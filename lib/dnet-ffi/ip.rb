
### libdnet's IP interface

module Dnet

  # ip_t * ip_open(void);
  attach_function :ip_open, [], :pointer

  # ssize_t ip_add_option(void *buf, size_t len, int proto, 
  #         const void *optbuf, size_t optlen);
  attach_function :ip_add_option, [ :string, :size_t, :int, :string, 
    :size_t ], :ssize_t

  # void ip_checksum(void *buf, size_t len);
  attach_function :ip_checksum, [:string, :size_t], :void

  # ssize_t ip_send(ip_t *i, const void *buf, size_t len);
  attach_function :ip_send, [:pointer, :string, :size_t], :ssize_t

  # ip_t * ip_close(ip_t *i);
  attach_function :ip_close, [:pointer], :pointer

  # void ip6_checksum(void *buf, size_t len);
  attach_function :ip6_checksum, [:string, :size_t], :void

end

