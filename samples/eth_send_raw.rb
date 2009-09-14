#!/usr/bin/env ruby

begin ; require 'rubygems'; rescue LoadError ; end
require 'dnet'
include Dnet

unless dev=ARGV.shift
  STDERR.puts "Usage: #{File.basename $0} interface"
  exit 1
end

STDERR.puts "Input data via stdin:"
data = STDIN.read

begin
  sent = Eth::Handle.open(dev) {|h| h.eth_send(data) }
rescue Exception => e
  STDERR.puts "Error: <#{e.class}> - #{e}"
  STDERR.puts " ** try running as root?" if e.is_a? Dnet::HandleError
  exit 1
end

if sent == data.size
  puts "Sent: #{sent} bytes"
  exit 0
else
  STDERR.puts "Error: expected #{data.size} sent bytes - got #{sent}"
  exit 1
end
