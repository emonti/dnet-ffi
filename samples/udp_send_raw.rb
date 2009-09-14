#!/usr/bin/env ruby
# A basic IP/UDP spoofing example using dnet-ffi libdnet ruby bindings.
#
# Usage: udp_send_raw.rb src-addr:sport dst-addr:dport [msg]
#
# Specify the contents for the udp message as 'msg', or via STDIN if no
# msg is supplied on the commandline.

begin ; require 'rubygems' ; rescue LoadError; end
require 'dnet'

include Dnet

arg_rx = %r{^(#{Util::RX_IP4_ADDR}):(\d+)$}
begin
  src_arg = ARGV.shift or raise "wrong arguments"
  dst_arg = ARGV.shift or raise "wrong arguments"
  raise "Invalid src addr" unless src_arg and sm=arg_rx.match(src_arg)
  raise "Invalid dst addr" unless dst_arg and dm=arg_rx.match(dst_arg)
  src = sm[1]
  sport = sm[2].to_i
  dst = dm[1]
  dport = dm[2].to_i
rescue
  STDERR.puts "Error: #{$!}"
  STDERR.puts "Usage: #{File.basename $0} src-addr:sport dst-addr:dport [msg]"
  exit 1
end

data=(ARGV.shift || STDIN.read)

blob = Blob.new

udp_sz = Udp::Hdr.size + data.size
tot_sz = Ip::Hdr.size + udp_sz


ip_hdr = Ip::Hdr.new :tos   => 0,
                     :len   => tot_sz,
                     :off   => 0, 
                     :ttl   => 128, 
                     :proto => Ip::Proto::UDP, 
                     :src   => src, 
                     :dst   => dst 

blob.write(ip_hdr.to_ptr,  Ip::Hdr.size)

udp_hdr = Udp::Hdr.new :sport => sport,
                       :dport => dport,
                       :len   => udp_sz

blob.write(udp_hdr.to_ptr, Udp::Hdr.size)

blob.write(data)

begin
  10.times do
    blob.rewind
    sent = Ip::Handle.open { |h| h.ip_send(blob.read) }
    if sent != tot_sz
      raise "expected #{tot_sz} bytes sent, but got #{sent}"
    else
      STDERR.puts "Sent: #{sent} bytes"
    end
  end
rescue ::Dnet::HandleError => e
  STDERR.puts "Error: <#{e.class}> - #{e}"
  STDERR.puts " ** try running as root?"
  exit 1
rescue Exception => e
  STDERR.puts "Error: <#{e.class}> - #{e}"
  exit 1
ensure
  blob.release
  blob=nil
end

exit 0
