require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Dnet::Rand" do
  context "dnet(3) rand_* function bindings" do
    funcs = %w{ rand_open rand_get rand_set rand_add rand_uint8 rand_uint16 rand_uint32 rand_shuffle rand_close }
    
    funcs.each do |func|
      it "should have bound: #{func}()" do
        ::Dnet.respond_to?(func).should == true
      end
    end

  end

end
