require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Dnet" do
  context "assert..." do
    # ...
  end
  context "Utilities" do
    [:htonl, :htons, :ntohl, :ntohs].each do |func|
      it "should have bound the utility C function #{func}()" do
        Dnet::Util.respond_to?(func).should == true
      end
    end

    context "long functions" do
      [:htonl, :ntohl].each do |func|
        it "should accept and return 32-bit numbers with #{func}()" do
          Dnet.__send__(func, 0xffffffff).should == 0xffffffff
        end
      end
    end

    context "short functions" do
      [:htons, :ntohs].each do |func|
        it "should accept and return 16-bit numbers with #{func}()" do
          Dnet.__send__(func, 0xffff).should == 0xffff
        end
      end
    end
  end
end

