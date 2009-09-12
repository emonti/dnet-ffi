require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Dnet::Eth" do

  context "dnet(3) function bindings" do
    funcs = %w{ eth_open eth_get eth_set eth_send eth_close }

    funcs.each do |func|
      it "should have bound: #{func}()" do
        ::Dnet.respond_to?(func).should == true
      end
    end

  end

  context "the Dnet::Eth module" do
    it "should be a module" do 
      Eth.kind_of?(Module).should == true
    end

    [:open, :eth_send].each do |meth|
      it "should provide a method called #{meth}()" do
        Eth.respond_to?(meth).should == true
      end
    end
  end

  context "the Eth::Handle class" do
    context "instance" do
      before(:all) do
        raise "!!! need an env. variable DNET_TEST_INTERFACE" unless NET_DEV
        begin
          @h = Eth::Handle.new(NET_DEV)
        rescue HandleError
          raise "!!! You may need to be root to run this test -- #{$!}"
        end
      end

      it "should have opened a handle" do
        @h.handle.kind_of?(::FFI::Pointer).should == true
      end

    end

  end

end
