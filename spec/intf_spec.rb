require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Dnet::Intf" do

  context "dnet(3) intf_* function bindings" do
    funcs = %w{ intf_open intf_get intf_get_src intf_get_dst intf_set intf_loop intf_close }

    funcs.each do |func|
      it "should have bound: #{func}()" do
        respond_to?(func).should == true
      end
    end

  end

  context "the Dnet::Intf module" do
    it "should be a module" do 
      Intf.kind_of?(Module).should == true
    end

    [:open, :each_entry, :entries].each do |meth|
      it "should provide a method called #{meth}()" do
        Intf.respond_to?(meth).should == true
      end
    end

    context "the each_entry() method" do
      it "should fire a block for each entry" do
        i=0
        Intf.each_entry {|e| i+=1 }
        i.should_not == 0
      end

      it "should yield interface entries to a block as Intf::Entry objects" do
        Intf.each_entry {|e| e.kind_of?(Intf::Entry).should == true }
      end

    end

    context "the entries() method" do
      before(:all) do
        @entries = Intf.entries()
      end

      it "should return an array of entries" do
        @entries.kind_of?(Array).should == true
      end

      it "should produce a non-emtpy entries list" do
        @entries.empty?.should == false
      end

      it "should produce entries containing interface entries" do
        @entries.each {|e| e.kind_of?(Intf::Entry).should == true }
      end

      it "should produce entries with interface name strings" do
        @entries.each {|e| e.if_name.kind_of?(String).should == true }
      end
    end

  end

  context "the Intf::Handle class" do
    context "instance" do
      before(:all) do
        @intf_h = Intf::Handle.new
      end

      it "should have opened a handle" do
        @intf_h.handle.kind_of?(::FFI::Pointer).should == true
      end

      it "should provide a way to get a list entries" do
        @intf_h.respond_to?(:entries).should == true
      end

      it "should provide that list as an array" do
        @intf_h.entries().kind_of?(Array).should == true
      end

      it "should provide interface entries in that array" do
        @intf_h.entries().each{|e| e.kind_of?(Intf::Entry).should == true}
      end

      it "should provide an iterator for entries" do
        @intf_h.respond_to?(:loop).should == true
      end

      it "should provide an interface entry through the iterator" do
        @intf_h.loop {|x| x.kind_of?(Intf::Entry).should == true }
      end

    end

  end

end
