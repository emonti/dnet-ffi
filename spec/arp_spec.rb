require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Dnet::Arp" do
  context "dnet(3) arp_* function bindings" do
    funcs = %w{ arp_open arp_add arp_delete arp_get arp_loop arp_close }

    funcs.each do |func|
      it "should have bound: #{func}()" do
        ::Dnet.respond_to?(func).should == true
      end
    end

  end

  context "the Dnet::Arp module" do
    it "should be a module" do 
      Arp.kind_of?(Module).should == true
    end

    [:open, :each_entry, :entries].each do |meth|
      it "should provide a method called #{meth}()" do
        Arp.respond_to?(meth).should == true
      end
    end

    context "the each_entry() method" do
      it "should fire a block for each entry" do
        i=0
        Arp.each_entry {|e| i+=1 }
        i.should_not == 0
      end

      it "should yield arp entries to a block as Arp::Entry objects" do
        Arp.each_entry {|e| e.kind_of?(Arp::Entry).should == true }
      end

    end

    context "the entries() method" do
      before(:all) do
        @entries = Arp.entries()
      end

      it "should return an array" do
        @entries.kind_of?(Array).should == true
      end

      it "should produce a non-emtpy list" do
        @entries.empty?.should == false
      end

      it "should produce arp entries as Arp::Entry objects" do
        @entries.each {|e| e.kind_of?(Arp::Entry).should == true }
      end

    end

  end

  context "the Dnet::Arp::Handle class" do
    context "instance" do
      before(:all) do
        @h = Arp::Handle.new
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

      it "should provide arp entries in that array" do
        @h.entries().each{|e| e.kind_of?(Arp::Entry).should == true}
      end

      it "should provide an iterator for entries" do
        @h.respond_to?(:loop).should == true
      end

      it "should provide arp entries through the iterator" do
        @h.loop {|x| x.kind_of?(Arp::Entry).should == true }
      end

    end

  end


end
