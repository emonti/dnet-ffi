# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{dnet-ffi}
  s.version = "0.1.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Eric Monti"]
  s.date = %q{2010-02-16}
  s.description = %q{Ruby FFI bindings for the libdnet raw network library}
  s.email = %q{emonti@matasano.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "History.txt",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "dnet-ffi.gemspec",
     "lib/dnet.rb",
     "lib/dnet/addr.rb",
     "lib/dnet/arp.rb",
     "lib/dnet/blob.rb",
     "lib/dnet/bsd.rb",
     "lib/dnet/constants.rb",
     "lib/dnet/eth.rb",
     "lib/dnet/fw.rb",
     "lib/dnet/helpers.rb",
     "lib/dnet/icmp.rb",
     "lib/dnet/intf.rb",
     "lib/dnet/ip.rb",
     "lib/dnet/ip6.rb",
     "lib/dnet/rand.rb",
     "lib/dnet/route.rb",
     "lib/dnet/tcp.rb",
     "lib/dnet/tun.rb",
     "lib/dnet/typedefs.rb",
     "lib/dnet/udp.rb",
     "lib/dnet/util.rb",
     "samples/eth_send_raw.rb",
     "samples/ifconfig-alike.rb",
     "samples/udp_send_raw.rb",
     "spec/addr_spec.rb",
     "spec/arp_spec.rb",
     "spec/blob_spec.rb",
     "spec/bsd_spec.rb",
     "spec/dnet-ffi_spec.rb",
     "spec/eth_spec.rb",
     "spec/fw_spec.rb",
     "spec/intf_spec.rb",
     "spec/ip6_spec.rb",
     "spec/ip_spec.rb",
     "spec/rand_spec.rb",
     "spec/route_spec.rb",
     "spec/spec_helper.rb",
     "spec/tun_spec.rb"
  ]
  s.homepage = %q{http://github.com/emonti/dnet-ffi}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Ruby FFI bindings for libdnet}
  s.test_files = [
    "spec/addr_spec.rb",
     "spec/arp_spec.rb",
     "spec/blob_spec.rb",
     "spec/bsd_spec.rb",
     "spec/dnet-ffi_spec.rb",
     "spec/eth_spec.rb",
     "spec/fw_spec.rb",
     "spec/intf_spec.rb",
     "spec/ip6_spec.rb",
     "spec/ip_spec.rb",
     "spec/rand_spec.rb",
     "spec/route_spec.rb",
     "spec/spec_helper.rb",
     "spec/tun_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<ffi_dry>, [">= 0.1.8"])
      s.add_runtime_dependency(%q<ffi-packets>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
    else
      s.add_dependency(%q<ffi_dry>, [">= 0.1.8"])
      s.add_dependency(%q<ffi-packets>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
    end
  else
    s.add_dependency(%q<ffi_dry>, [">= 0.1.8"])
    s.add_dependency(%q<ffi-packets>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
  end
end

