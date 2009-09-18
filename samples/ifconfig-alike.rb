#!/usr/bin/env ruby

begin; require 'rubygems' ; rescue LoadError; end
require 'dnet'

@arg_if = ARGV.shift

module Dumper
  def self.dump_if_inet(a)
    return "#{a.lookup_atype} address: #{a.string} net: #{a.net.string} "+
           "bcast: #{a.bcast.string}"
  end

  def self.dump_if_inet6(a)
    return "#{a.lookup_atype} address: #{a.string} net: #{a.net.string} "
  end

  def self.dump_if_link(a)
    return "#{a.lookup_atype} address: #{a.string}"
  end
end

Dnet::IntfHandle.each_entry do |entry|
  next if @arg_if and entry.if_name != @arg_if

  puts("#{entry.if_name}: "+
       "type=#{entry.lookup_itype.downcase} "+
       "flags=#{entry.flags}<#{entry.lookup_flags.join(',')}> "+
       "mtu #{entry.mtu}\n" )

  [:if_addr, :link_addr, :dst_addr].each do |addr_field|
    addr = entry.send(addr_field)
    if kind=addr.lookup_atype
      puts "    " + Dumper.__send__(:"dump_if_#{kind}", addr)
    end
  end

  entry.aliases.each do |alias_addr|
    if kind = alias_addr.lookup_atype
      puts "    alias: " + Dumper.__send__(:"dump_if_#{kind}", alias_addr)
    end
  end
end

