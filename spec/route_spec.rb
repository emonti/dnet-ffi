require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Dnet::Route" do
  context "dnet(3) route_* function bindings" do
    funcs = %w{ route_open route_add route_delete route_get route_loop route_close }

    funcs.each do |func|
      it "should have bound: #{func}()" do
        ::Dnet.respond_to?(func).should == true
      end
    end

  end

  context "the Dnet::Route module" do
    it "should be a module" do 
      Route.kind_of?(Module).should == true
    end

    [:open, :each_entry, :entries].each do |meth|
      it "should provide a method called #{meth}()" do
        Route.respond_to?(meth).should == true
      end
    end

    context "the each_entry() method" do
      it "should fire a block for each entry" do
        i=0
        Route.each_entry {|e| i+=1 }
        i.should_not == 0
      end

      it "should yield route entries to a block as Route::Entry objects" do
        Route.each_entry {|e| e.kind_of?(Route::Entry).should == true }
      end

    end

    context "the entries() method" do
      before(:all) do
        @entries = Route.entries()
      end

      it "should return an array" do
        @entries.kind_of?(Array).should == true
      end

      it "should produce a non-emtpy list" do
        @entries.empty?.should == false
      end

      it "should produce route entries as Route::Entry objects" do
        @entries.each {|e| e.kind_of?(Route::Entry).should == true }
      end

    end

  end

  context "the Dnet::Route::Handle class" do
    context "instance" do
      before(:all) do
        @h = Route::Handle.new
      end

      it "should have opened a handle" do
        @h.handle.kind_of?(::FFI::Pointer).should == true
      end

      it "should provide a way to get a list of entries" do
        @h.respond_to?(:entries).should == true
      end

      it "should provide that list as an array" do
        @h.entries().kind_of?(Array).should == true
      end

      it "should provide route entries in that array" do
        @h.entries().each{|e| e.kind_of?(Route::Entry).should == true}
      end

      it "should provide an iterator for entries" do
        @h.respond_to?(:loop).should == true
      end

      it "should provide route entries through the iterator" do
        @h.loop {|x| x.kind_of?(Route::Entry).should == true }
      end

    end

  end

end
