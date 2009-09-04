module Dnet

  ### Firewalling

  # typedef int (*fw_handler)(const struct fw_rule *rule, void *arg);
  callback :fw_handler, [:pointer, :string], :int

  # fw_t *
  # fw_open(void);
  attach_function :fw_open, [], :pointer

  # int
  # fw_add(fw_t *f, const struct fw_rule *rule);
  attach_function :fw_add, [:pointer, :pointer], :int

  # int
  # fw_delete(fw_t *f, const struct fw_rule *rule);
  attach_function :fw_delete, [:pointer, :pointer], :int

  # int
  # fw_loop(fw_t *f, fw_handler callback, void *arg);
  attach_function :fw_loop, [:pointer, :fw_handler, :string], :int

  # fw_t *
  # fw_close(fw_t *f);
  attach_function :fw_close, [:pointer], :pointer


  ### Network interfaces

  # typedef int (*intf_handler)(const struct intf_entry *entry, void *arg);
  callback :intf_handler, [:pointer, :string] , :int

  # intf_t *
  # intf_open(void);
  attach_function :intf_open, [], :pointer

  # int
  # intf_get(intf_t *i, struct intf_entry *entry);
  attach_function :intf_get, [:pointer, :pointer], :int

  # int
  # intf_get_src(intf_t *i, struct intf_entry *entry, struct addr *src);
  attach_function :intf_get_src, [:pointer, :pointer, :pointer], :int

  # int
  # intf_get_dst(intf_t *i, struct intf_entry *entry, struct addr *dst);
  attach_function :intf_get_dst, [:pointer, :pointer, :pointer], :int

  # int
  # intf_set(intf_t *i, const struct intf_entry *entry);
  attach_function :intf_set, [:pointer, :pointer], :int

  # int
  # intf_loop(intf_t *i, intf_handler callback, void *arg);
  attach_function :intf_loop, [:pointer, :intf_handler, :string], :int

  # intf_t *
  # intf_close(intf_t *i);
  attach_function :intf_close, [:pointer], :pointer


  ### Internet Protocol

  # ip_t *
  # ip_open(void);
  attach_function :ip_open, [], :pointer

  # ssize_t
  # ip_add_option(void *buf, size_t len, int proto, const void *optbuf,
  #         size_t optlen);
  attach_function :ip_add_option, [ :string, :size_t, :int, :string, 
    :size_t ], :ssize_t

  # void
  # ip_checksum(void *buf, size_t len);
  attach_function :ip_checksum, [:string, :size_t], :void

  # ssize_t
  # ip_send(ip_t *i, const void *buf, size_t len);
  attach_function :ip_send, [:pointer, :string, :size_t], :ssize_t

  # ip_t *
  # ip_close(ip_t *i);
  attach_function :ip_close, [:pointer], :pointer


  ### Internet Protocol Version 6

  # void
  # ip6_checksum(void *buf, size_t len);
  attach_function :ip6_checksum, [:string, :size_t], :void


  ### Random number generation

  # rand_t *
  # rand_open(void);
  attach_function :rand_open, [], :pointer

  # int
  # rand_get(rand_t *r, void *buf, size_t len);
  attach_function :rand_get, [:pointer, :string, :size_t], :int

  # int
  # rand_set(rand_t *r, const void *seed, size_t len);
  attach_function :rand_set, [:pointer, :string, :size_t], :int

  # int
  # rand_add(rand_t *r, const void *buf, size_t len);
  attach_function :rand_add, [:pointer, :string, :size_t], :int

  # uint8_t
  # rand_uint8(rand_t *r);
  attach_function :rand_uint8, [:pointer], :uint8

  # uint16_t
  # rand_uint16(rand_t *r);
  attach_function :rand_uint16, [:pointer], :uint16

  # uint32_t
  # rand_uint32(rand_t *r);
  attach_function :rand_uint32, [:pointer], :uint32

  # int
  # rand_shuffle(rand_t *r, void *base, size_t nmemb, size_t size);
  attach_function :rand_shuffle, [:pointer, :string, :size_t, :size_t], :int

  # rand_t *
  # rand_close(rand_t *r);
  attach_function :rand_close, [:pointer], :pointer


  ### Routing

  # typedef int (*route_handler)(const struct route_entry *entry, void *arg);
  callback :route_handler, [:pointer, :string], :int

  # route_t *
  # route_open(void);
  attach_function :route_open, [], :pointer

  # int
  # route_add(route_t *r, const struct route_entry *entry);
  attach_function :route_add, [:pointer, :pointer], :int

  # int
  # route_delete(route_t *r, const struct route_entry *entry);
  attach_function :route_delete, [:pointer, :pointer], :int

  # int
  # route_get(route_t *r, struct route_entry *entry);
  attach_function :route_get, [:pointer, :pointer], :int

  # int
  # route_loop(route_t *r, route_handler callback, void *arg);
  attach_function :route_loop, [:pointer, :route_handler, :string], :int

  # route_t *
  # route_close(route_t *r);
  attach_function :route_close, [:pointer], :pointer


  ### Tunnel interface

  # tun_t *
  # tun_open(struct addr *src, struct addr *dst, int mtu);
  attach_function :tun_open, [:pointer, :pointer, :int], :pointer

  # int
  # tun_fileno(tun_t *t);
  attach_function :tun_fileno, [:pointer], :int

  # const char *
  # tun_name(tun_t *t);
  attach_function :tun_name, [:pointer], :string

  # ssize_t
  # tun_send(tun_t *t, const void *buf, size_t size);
  attach_function :tun_send, [:pointer, :string, :size_t], :ssize_t

  # ssize_t
  # tun_recv(tun_t *t, void *buf, size_t size);
  attach_function :tun_recv, [:pointer, :string, :size_t], :ssize_t

  # tun_t *
  # tun_close(tun_t *t);
  attach_function :tun_close, [:pointer], :pointer

end
