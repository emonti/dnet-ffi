# Bindings for dnet(3)'s arp_* API

module Dnet

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
        raise ::Dnet::HandleError.new("handle is closed") unless @handle_open
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
    # XXX this is buggin... looks like we end up with stale pointers?
    # def self.entries
    #   ary = []
    #   each_entry {|x| ary << x}
    #   return ary
    # end

    private
      # Generic helper for libdnet's *_loop method interfaces.
      # Calls Dnet."loop_meth" to loop through some sort of entry which is cast
      # to a new instance of 'entry_cast' class and yielded to a block.
      def _loop(loop_meth, entry_cast)
        _check_open!
        b = lambda {|e, i| yield entry_cast.new(e); nil } 
        ::Dnet.__send__ loop_meth, @handle, b, self.object_id
      end

  end

end
