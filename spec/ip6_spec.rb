require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Dnet::Addr" do
  context "dnet(3) function bindings" do
    funcs = %w{ ip6_checksum }

    funcs.each do |func|
      it "should have bound: #{func}()" do
        ::Dnet.respond_to?(func).should == true
      end
    end

  end

end
