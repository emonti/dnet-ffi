
### dnet(3) routing interface

module Dnet

  module Route
    # Routing table entry
    #
    #   struct route_entry {
    #      struct addr    route_dst;   /* destination address */
    #      struct addr    route_gw;    /* gateway address */
    #   };
    class Entry < ::FFI::Struct
      include ::FFI::DRY::StructHelper
    
      dsl_layout do
        struct :dst, ::Dnet::Addr, :dest => 'destination gateway'
        struct :gw,  ::Dnet::Addr, :dest => 'gateway address'
      end
    end

    # Obtains a handle to access the kernel route(4) table.
    class Handle < LoopableHandle
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
      # with each route cast as a Entry object. Uses dnet(3)'s route_loop() 
      # function under the hood.
      def loop &block
        _loop ::Dnet, :route_loop, Entry, &block
      end

      # Retrieves the routing table entry for the destination 'dst' (supplied as
      # a String argument and parsed via dnet(3)'s addr_aton() function). Uses 
      # dnet(3)'s route_get() under the hood.
      def get(dst)
        _check_open!
        re = Entry.new
        if( re.dst.set_string(dst) and ::Dnet.route_get(@handle, re) == 0 )
          return re 
        end
      end


      # Adds a new routing table entry (supplied as a Entry). Uses dnet(3)'s 
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
        re = Entry.new
        if( re.dst.set_string(dst) and ::Dnet.route_get(@handle, re) == 0 )
          return re 
        end
      end
    end # Handle

    def self.open(*args)
      Handle.open(*args){|*y| yield(*y) if block_given? }
    end

    def self.entries
      Handle.entries
    end

    def self.each_entry(*args)
      Handle.each_entry(*args){|*y| yield(*y) }
    end
  end # Route

  # just an alias for Route::Handle
  RouteHandle = Route::Handle

  callback :route_handler, [:route_t, :string], :int
  attach_function :route_open, [], :route_t
  attach_function :route_add, [:route_t, Route::Entry], :int
  attach_function :route_delete, [:route_t, Route::Entry], :int
  attach_function :route_get, [:route_t, Route::Entry], :int
  attach_function :route_loop, [:route_t, :route_handler, :ulong], :int
  attach_function :route_close, [:route_t], :route_t

end
