require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Dnet::Blob" do
  context "dnet(3) blob_* function bindings" do
    funcs = %w{ blob_new blob_read blob_write blob_seek blob_index blob_rindex blob_pack blob_unpack blob_print blob_free }

    funcs.each do |func|
      it "should have bound: #{func}()" do
        ::Dnet.respond_to?(func).should == true
      end
    end

  end

end
