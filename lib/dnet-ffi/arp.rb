# Address resolution Protocol

module Dnet
  # ARP cache entries are described by the following structure:

  # The callback definition used by arp_loop
  #   typedef int (*arp_handler)(const struct arp_entry *entry, void *arg);
  callback :arp_handler, [:pointer, :string], :int

  # arp_open is used to obtain a handle to access the kernel arp(4) cache.
  #
  #   arp_t * arp_open(void);
  attach_function :arp_open, [], :pointer

  # arp_add adds a new ARP entry.
  #
  #   int arp_add(arp_t *a, const struct arp_entry *entry);
  attach_function :arp_add, [:pointer, :pointer], :int

  # arp_delete deletes the ARP entry for the protocol address specified by
  # arp_pa.
  #
  #   int arp_delete(arp_t *a, const struct arp_entry *entry);
  attach_function :arp_delete, [:pointer, :pointer], :int


  # arp_get retrieves the ARP entry for the protocol address specified by
  # arp_pa.
  #
  #   int arp_get(arp_t *a, struct arp_entry *entry);
  attach_function :arp_get, [:pointer, :pointer], :int

  # arp_loop iterates over the kernel arp cache, invoking the specified
  # callback with each entry and the context arg passed to arp_loop.
  #
  #   int arp_loop(arp_t *a, arp_handler callback, void *arg);
  attach_function :arp_loop, [:pointer, :arp_handler, :string], :int

  # arp_close closes the specified handle.
  #
  #   arp_t * arp_close(arp_t *a);
  attach_function :arp_close, [:pointer], :pointer


  # FFI mapping to libdnet's "arp_entry" struct.
  #
  # libnet's ARP cache entries are described by the following C structure:
  # 
  #   struct arp_entry {
  #          struct addr     arp_pa;         /* protocol address */
  #          struct addr     arp_ha;         /* hardware address */
  #   };
  #
  class Arp < FFI::Struct

    # struct arp_entry { ... };
    layout( :arp_pa, ::Dnet::Addr,   # protocol address
            :arp_ha, ::Dnet::Addr )  # hardware address

  end
end
