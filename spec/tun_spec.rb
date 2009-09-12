require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Dnet::Tun" do
  context "dnet(3) tun_* function bindings" do
    funcs = %w{ tun_open tun_fileno tun_name tun_send tun_recv tun_close }

    funcs.each do |func|
      it "should have bound: #{func}()" do
        ::Dnet.respond_to?(func).should == true
      end
    end

  end

end
