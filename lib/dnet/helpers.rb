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

    # shorthand for the HandleError exception class
    H_ERR = HandleError

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

    def entries
      ary = []
      self.loop {|e| ary << e.copy }
      return ary
    end

    # Yields each entry via a new instance through loop() to a block
    def self.each_entry(*args)
      open(*args) {|a| a.loop {|e| yield e } }
    end

    # Returns all entries as an array.
    def self.entries(*args)
      open(*args) {|a| a.entries }
    end

    private
      # Generic helper for libdnet's *_loop method interfaces.
      # Calls Dnet."loop_meth" to loop through some sort of entry which is cast
      # to a new instance of 'entry_cast' class and yielded to a block.
      def _loop(nspace, loop_meth, entry_cast)
        _check_open!
        b = lambda {|e, i| yield entry_cast.new(e); nil } 
        nspace.__send__ loop_meth, @handle, b, self.object_id
      end

  end # LoopableHandle

  # A special helper for network packet structures which use big-endian or
  # "network" byte-order. This helper generates read/write accessors that
  # automatically call the appropriate byte conversion function, ntohs/ntohl
  # for 'reading' a 16/32 bit field, and htons/htonl for writing to one.
  #
  # NOTE this helper does not currently do anything special for 64-bit values 
  # at all.
  #
  # This helper relies on a included loaded FFI::DRY::StructHelper module
  # to do its magic. Always include this module as follows:
  #
  #   class YourStruct < ::FFI::Struct # or ::FFI::ManagedStruct, (or Union?)
  #     include ::FFI::DRY::StructHelper
  #     include ::Dnet::NetStructBE
  #     ...
  #
  module NetStructBE

    I16_convert = [::Dnet.method(:ntohs), ::Dnet.method(:htons)]
    U16_convert = [::Dnet.method(:ntohs), ::Dnet.method(:htons)]
    I32_convert = [::Dnet.method(:ntohl), ::Dnet.method(:htonl)]
    U32_convert = [::Dnet.method(:ntohl), ::Dnet.method(:htonl)]

    BYTE_ORDER_METH = {
      Dnet.find_type(:uint16) => I16_convert,
      Dnet.find_type(:int16)  => I16_convert,
      Dnet.find_type(:int32)  => I32_convert,
      Dnet.find_type(:uint32) => I32_convert,
    }

    module ClassMethods
      private
      def _class_do_dsl_metadata(meta)
        (@dsl_metadata = meta).each do |spec|
          name = spec[:name]
          type = spec[:type]
          if type.kind_of? Symbol and mp=BYTE_ORDER_METH[ Dnet.find_type(type) ]
            unless instance_methods.include?(:"#{name}")
              define_method(:"#{name}"){ mp[0].call(self[name]) }
            end
            unless instance_methods.include?(:"#{name}=")
              define_method(:"#{name}="){|val| self[name] = mp[1].call(val) }
            end
          else
            unless instance_methods.include?(:"#{name}")
              define_method(:"#{name}"){ self[name] } 
            end
            unless instance_methods.include?(:"#{name}=")
              define_method(:"#{name}="){|val| self[name]=val }
            end 
          end
        end
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

  end
end

