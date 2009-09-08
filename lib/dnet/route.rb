
### dnet(3) routing interface

module Dnet

  #  /*
  #   * Routing table entry
  #   */
  #  struct route_entry {
  #      struct addr    route_dst;   /* destination address */
  #      struct addr    route_gw;    /* gateway address */
  #  };
  class RouteEntry < FFI::Struct
    layout( :dst, ::Dnet::Addr,
            :gw,  ::Dnet::Addr )

    def dst ; self[:dst] ; end
    def gw ; self[:gw] ; end
  end

  class RouteHandle < LoopableHandle
    attr_reader :handle

    # Obtains a handle to access the kernel route(4) table. Uses dnet(3)'s 
    # route_open() under the hood.
    def initialize
      if (@handle = ::Dnet.route_open()).address == 0
        raise H_ERR.new("unable to open route handle")
      end
      _handle_opened!
    end

    # Closes the routing handle handle. Uses dnet(3)'s route_close() under the
    # hood.
    def close
      _do_if_open { _handle_closed! ; ::Dnet.route_close(@fw) }
    end

    # Iterates over the kernel route(4) table, invoking the specified block
    # with each route cast as a RouteEntry object. Uses dnet(3)'s route_loop() 
    # function under the hood.
    def loop &block
      _loop :route_loop, RouteEntry, &block
    end

    # Retrieves the routing table entry for the destination 'dst' (supplied as
    # a String argument and parsed via dnet(3)'s addr_aton() function). Uses 
    # dnet(3)'s route_get() under the hood.
    def get(dst)
      _check_open!
      re = RouteEntry.new
      if( re.dst.set_string(dst) and ::Dnet.route_get(@handle, re) == 0 )
        return re 
      end
    end


    # Adds a new routing table entry (supplied as a RouteEntry). Uses dnet(3)'s 
    # route_add() under the hood.
    def add(entry)
      _check_open!
      ::Dnet.route_add(@handle, entry)
    end

    # Delete's the specified route entry for the destination prefix specified
    # by the destination 'dst' (supplied as a String argument and parsed
    # by dnet(3)'s addr_aton function). 
    def delete(dst)
      _check_open!
      re = RouteEntry.new
      if( re.dst.set_string(dst) and ::Dnet.route_get(@handle, re) == 0 )
        return re 
      end
    end
  end

  typedef :pointer, :route_t
  callback :route_handler, [:route_t, :string], :int
  attach_function :route_open, [], :route_t
  attach_function :route_add, [:route_t, RouteEntry], :int
  attach_function :route_delete, [:route_t, RouteEntry], :int
  attach_function :route_get, [:route_t, RouteEntry], :int
  attach_function :route_loop, [:route_t, :route_handler, :ulong], :int
  attach_function :route_close, [:route_t], :route_t

end
