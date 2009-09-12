require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Dnet::Ip" do
  context "dnet(3) ip_* function bindings" do
    funcs = %w{ ip_open ip_add_option ip_checksum ip_send ip_close }

    funcs.each do |func|
      it "should have bound: #{func}()" do
        ::Dnet.respond_to?(func).should == true
      end
    end

  end

end
