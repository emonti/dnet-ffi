
### libdnet's api for network interfaces

module Dnet

  # typedef int (*intf_handler)(const struct intf_entry *entry, void *arg);
  callback :intf_handler, [:pointer, :string] , :int

  # intf_t * intf_open(void);
  attach_function :intf_open, [], :pointer

  # int intf_get(intf_t *i, struct intf_entry *entry);
  attach_function :intf_get, [:pointer, :pointer], :int

  # int intf_get_src(intf_t *i, struct intf_entry *entry, struct addr *src);
  attach_function :intf_get_src, [:pointer, :pointer, :pointer], :int

  # int intf_get_dst(intf_t *i, struct intf_entry *entry, struct addr *dst);
  attach_function :intf_get_dst, [:pointer, :pointer, :pointer], :int

  # int intf_set(intf_t *i, const struct intf_entry *entry);
  attach_function :intf_set, [:pointer, :pointer], :int

  # int intf_loop(intf_t *i, intf_handler callback, void *arg);
  attach_function :intf_loop, [:pointer, :intf_handler, :string], :int

  # intf_t * intf_close(intf_t *i);
  attach_function :intf_close, [:pointer], :pointer

end
