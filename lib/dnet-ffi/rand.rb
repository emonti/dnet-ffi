
### libdnet's random number generation

module Dnet

  # rand_t * rand_open(void);
  attach_function :rand_open, [], :pointer

  # int rand_get(rand_t *r, void *buf, size_t len);
  attach_function :rand_get, [:pointer, :string, :size_t], :int

  # int rand_set(rand_t *r, const void *seed, size_t len);
  attach_function :rand_set, [:pointer, :string, :size_t], :int

  # int rand_add(rand_t *r, const void *buf, size_t len);
  attach_function :rand_add, [:pointer, :string, :size_t], :int

  # uint8_t rand_uint8(rand_t *r);
  attach_function :rand_uint8, [:pointer], :uint8

  # uint16 t rand_uint16(rand_t *r);
  attach_function :rand_uint16, [:pointer], :uint16

  # uint32_t rand_uint32(rand_t *r);
  attach_function :rand_uint32, [:pointer], :uint32

  # int rand_shuffle(rand_t *r, void *base, size_t nmemb, size_t size);
  attach_function :rand_shuffle, [:pointer, :string, :size_t, :size_t], :int

  # rand_t * rand_close(rand_t *r);
  attach_function :rand_close, [:pointer], :pointer

end
