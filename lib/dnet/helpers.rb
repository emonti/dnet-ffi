# This file contains various helper methods, modules, and classes used 
# throughout the Dnet FFI bindings.

module Dnet

  # Produces a null-terminated string from 'val', if max is supplied,
  # it is taken as a maximum length. If 'val' is longer than max, it will
  # be truncated to max-1 with a terminating null.
  def self.truncate_cstr(val, max=nil)
    ret = (max and val.size > (max-1))? val[0,max-1] : val
    ret << "\x00"
    return ret
  end

  # An exception class raised on Handle related errors.
  class HandleError < Exception; end

  # A helper used for maintaining open/close state on libdnet's handles and 
  # volatile objects.
  module HandleHelpers

    # shorthand for the ::Dnet::HandleError exception class
    H_ERR = ::Dnet::HandleError

    def open? ; _handle_open? ; end
    def closed? ; (not _handle_open?) ; end

    private
      def _handle_opened!
        @handle_open = true
      end

      def _handle_closed!
        @handle_open = false
      end

      def _check_open!
        raise H_ERR.new("handle is closed") unless @handle_open
      end

      def _handle_open?
        @handle_open
      end

      def _do_if_open
        yield if @handle_open
      end
  end

  class Handle
    include HandleHelpers

    attr_reader :handle

    # Opens a new handle object, optionally yielding it to a block.
    #
    # If a block is supplied, the handle will be closed after completion
    # and the result of the block returned. Otherwise, the new handle is 
    # returned in an open state.
    def self.open(*args)
      o=new(*args)
      return o unless block_given?
      begin yield(o) ensure o.close end
    end
  end

  class LoopableHandle < Handle

    # Yields each entry via a new instance through loop() to a block
    def self.each_entry
      open {|a| a.loop {|e| yield e } }
    end

    # Returns all entries as an array.
    def self.entries
      ary = []
      each_entry {|x| ary << x.copy }
      return ary
    end

    private
      # Generic helper for libdnet's *_loop method interfaces.
      # Calls Dnet."loop_meth" to loop through some sort of entry which is cast
      # to a new instance of 'entry_cast' class and yielded to a block.
      def _loop(loop_meth, entry_cast)
        _check_open!
        b = lambda {|e, i| yield entry_cast.new(e); nil } 
        ::Dnet.__send__ loop_meth, @handle, b, self.object_id
      end

  end # LoopableHandle

  # A exception class for errors generated through the SugarStruct module
  class StructError < ::Exception; end

  # Adds some sugar to the base FFI::Struct class.
  #
  # XXX maybe this wants to be a module so it can be shared with ManagedStruct,
  # Union, etc.
  class SugarStruct < ::FFI::Struct

    # shortcut for ::Dnet::StructError
    S_ERR = ::Dnet::StructError

    # Adds field setting on initialization to ::FFI::Struct.new as well as
    # a "yield(self) if block_given?" at the end.
    #
    # The field initialization kicks in if there is only one argument, and it 
    # is a Hash. 
    #
    # Note: 
    # The :raw parameter is a special tag in the hash. The value is taken as a 
    # string and initialized into a new FFI::MemoryPointer which this Struct 
    # then overlays.
    #
    # If your struct layout has a field named :raw field, it won't be 
    # assignable through the hash argument.
    #
    # See also: set_fields() which is called automatically on the hash, minus
    # the :raw tag.
    #
    # Below are several examples:
    #
    #    ss=SomeStruct.new :raw => raw_data, :field1 => 1, :field3 => 2
    #
    #   # or...
    #
    #    ss=SomeStruct.new {|x| x.field1=1; x.field3=2 }
    #
    #   # or...
    # 
    #    ss=SomeStruct.new(:raw => raw_data) {|x| x.field1=1 }
    #
    def initialize(*args)
      if args.size == 1 and (oparams=args[0]).is_a? Hash
        params = oparams.dup
        if raw=params.delete(:raw)
          super( ::FFI::MemoryPointer.from_string(raw) )
        else
          super()
        end
        set_fields(params)
      else
        super(*args)
      end

      yield self if block_given?
    end

    # Sets field values in the struct specified by their symbolic name from a 
    # hash of ':field => value' pairs. Uses accessor field wrapper methods 
    # (as in "obj.field1 = x" instead of "obj[:field] = x")
    #
    # This method is called automatically if you are using the new() method
    # provided in the SugarStruct helper and passing it a Hash as its only
    # argument.
    def set_fields(params)
      params.keys.each do |p|
        if @reject_hash_set and @reject_hash_set.include?(p)
          err = "can't use set_fields with `#{p}'"
          if msg=@reject_hash_set[p]
            err << ": #{msg}" 
          end
          raise(S_ERR, "cant use set_fields with '#{p}': #{msg}")
        elsif members().include?(p)
          self.__send__ :"#{p}=", params[p]
        else
          raise S_ERR.new("#{self.class} does not have a '#{p}' field")
        end
      end
    end

    # Attempts to resolve calls as read/write accessors for structure fields 
    # (i.e. you automatically get a "obj.field" and "obj.field=(x)" method 
    # for every structure member).
    #
    # This convention can be followed in custom accessors that take inputs
    # or return values in a specific format.
    #
    # It can be desirable to have accessors using different formats for calls
    # between what's returned from "obj.fieldX" and "obj[:fieldX]", as well as 
    # a difference between what you supply via "obj.fieldX=y" and 
    # "obj[:field]=y". However, ideally the format for set( obj.fieldX=... ) 
    # and get( obj.fieldX() ) should always match.
    def method_missing(m, *args)
      mstr = m.to_s ;  msym = m.to_sym
      asz = args.size
      if( mstr[-1,1] == "=" and (not (mset=mstr[0..-2]).empty?) and 
          members.include?(:"#{mset}") )
        if asz != 1
          raise(::ArgumentError, ("wrong number of arguments (#{asz} for 1)"))
        end
        self[:"#{mset}"] = args[0]
      elsif members().include?(msym)
        if asz != 0
          raise(::ArgumentError, "wrong number of arguments (#{asz} for 0)")
        end
        self[msym]
      else
        raise(::NoMethodError, "undefined method `#{m}' for #{self.inspect}")
      end
    end


    # Returns a new instance of self.class containing a seperately allocated 
    # copy of all our data. This abstract method can be called from overridden 
    # 'copy()' implementations. 
    #
    # Note that this determine's size automatically based on the structure size.
    # This may not be what you want if your structure contains variable-length
    # data. Screw it up, and don't be supprised if you get weird/missing data 
    # or worse -- segfaults and bus error crashes from ruby.
    #
    # Implementing a correct 'copy' is required for structures passed to
    # the looping callbacks. These callbacks are found throughout the dnet(3) 
    # API. The instances passed into the callback are free'd as soon as the 
    # yield is finished.
    #
    # For example:
    #
    #    ary =[]
    #    # => []
    #    Dnet::Arp::Handle.each_entry do |en| 
    #           ary << en.copy
    #           ary << en
    #    end
    #    # => 0
    #    ary.each {|x| p [x.pa.addr, x.ha.addr] }
    #    #["192.168.116.4", "de:ad:be:ef:ba:be"]  # the copy
    #    #[nil, nil]                              # original
    #    # => [#<Dnet::Arp::Entry:0x5017e8>, #<Dnet::Arp::Entry:0x501978>]
    #  
    # Only the entry that was copied is now usable outside the each_entry 
    # block. This is because the entry passed into the block ('en') was freed 
    # by eth_loop after FFI called back to the block.
    # 
    # Copying can get hairy when your structure contains fields that are 
    # pointers. But that's what overriding is for. Just allocate and copy
    # over to new pointers, then assign the structure members.
    # 
    # This method also includes a 'grown' parameter which is added to the
    # size of the struct when allocating and copying over the new data.
    def copy(grown=0)
      self.class.new( :raw => self.to_ptr.read_string(self.size+grown) )
    end

  end # SugarStruct


  # Used for creating various value <=> constant mapping modules such as 
  # Ip::Hdr::Proto for IP protocols.
  module ConstList

    def self.included(klass)
      klass.extend(::Dnet::ConstList)
    end

    # A flexible lookup. Takes a Symbol or String as a name to lookup a value, 
    # or an integer to lookup a corresponding name.
    def [](arg)
      if arg.is_a? Integer
        list.invert[arg]
      elsif arg.is_a? String or arg.is_a? Symbol
        list[arg.to_s.upcase]
      end
    end

    def list
      constants.inject({}){|h,c| h.merge! c => const_get(c) }
    end

    private
      def slurp_constants(nspace, prefix)
        ::Dnet.constants.grep(/^(#{prefix}([A-Z][A-Z0-9_]+))$/) do
          const_set $2, ::Dnet.const_get($1)
        end
      end
  end

end

