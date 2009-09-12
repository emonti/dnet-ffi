require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Dnet::AF" do
  context "address family lookups" do
    it "should map constants for addres families" do
      Dnet::AF.const_get("LINK").should == Socket::AF_LINK
      Dnet::AF.const_get("INET").should == Socket::AF_INET
      Dnet::AF.const_get("INET6").should == Socket::AF_INET6
    end

    it "should identify socket addr family names by number" do
      Dnet::AF[ Socket::AF_LINK ].should == "LINK"
      Dnet::AF[ Socket::AF_INET ].should == "INET"
      Dnet::AF[ Socket::AF_INET6 ].should == "INET6"
    end

    it "should identify socket addr numbers by string name" do
      Dnet::AF[ "LINK" ].should == Socket::AF_LINK
      Dnet::AF[ "INET" ].should == Socket::AF_INET
      Dnet::AF[ "INET6" ].should == Socket::AF_INET6
    end

    it "should identify socket addr numbers by symbol name" do
      Dnet::AF[ :link ].should == Socket::AF_LINK
      Dnet::AF[ :inet ].should == Socket::AF_INET
      Dnet::AF[ :inet6 ].should == Socket::AF_INET6
    end


  end
end
