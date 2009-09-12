require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Dnet::Addr" do
  context "dnet(3) addr_* function bindings" do
    funcs = %w{addr_cmp addr_bcast addr_net addr_ntop addr_pton addr_ntoa addr_aton addr_ntos addr_ston addr_btos addr_stob addr_btom addr_mtob}

    funcs.each do |func|
      it "should have bound: #{func}()" do
        ::Dnet.respond_to?(func).should == true
      end
    end

  end

end
