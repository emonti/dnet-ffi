
### libdnet's tunnel interface

module Dnet

  # tun_t * tun_open(struct addr *src, struct addr *dst, int mtu);
  attach_function :tun_open, [:pointer, :pointer, :int], :pointer

  # int tun_fileno(tun_t *t);
  attach_function :tun_fileno, [:pointer], :int

  # const char * tun_name(tun_t *t);
  attach_function :tun_name, [:pointer], :string

  # ssize_t tun_send(tun_t *t, const void *buf, size_t size);
  attach_function :tun_send, [:pointer, :string, :size_t], :ssize_t

  # ssize_t tun_recv(tun_t *t, void *buf, size_t size);
  attach_function :tun_recv, [:pointer, :string, :size_t], :ssize_t

  # tun_t * tun_close(tun_t *t);
  attach_function :tun_close, [:pointer], :pointer

end
