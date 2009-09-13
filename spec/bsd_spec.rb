require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Dnet::AF" do
  context "address family lookups" do
    it "should map constants for address families" do
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

describe "SockAddrIn" do
  context "from Socket::pack_sockaddr_in / to unpack_sockaddr_in" do
    before(:all) do
      @raw= ::Socket.pack_sockaddr_in(9999, "127.0.0.1")
      @sa = ::Dnet::SockAddrIn.new :raw => @raw
    end

    it "should capture a packed sockaddr_in" do
      @sa.to_ptr.read_string(@sa.size).should == @raw
    end

    it "should return the correct family value family()" do
      @sa.family.should == ::Socket::AF_INET
    end

    it "should return the correct family name with lookup_family()" do
      @sa.lookup_family.should == "INET"
    end

    it "should return 8 bytes of null data starting at :_sa_zero" do
      (@sa.to_ptr + @sa.offset_of(:_sa_zero)).read_string(8).should == "\x00"*8
    end

    it "should unpack to the correct address" do
      (::Socket.unpack_sockaddr_in(@sa.to_ptr.read_string(@sa.size))).should == [9999, "127.0.0.1"]
    end
  end

end
