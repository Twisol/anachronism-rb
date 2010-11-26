#!/usr/bin/env ruby


module Anachronism
  VERSION = "0.0.1"
end

$:.unshift '../ext'
require 'anachronism.so'

data = "foo\r\n\r\0bar".force_encoding("ASCII-8BIT")
data2 = "\xFF\xFF\xFF\xF6lolwat".force_encoding("ASCII-8BIT")

telnet = Anachronism::Parser.new
events = telnet.process(data)
events.concat telnet.process(data2)

events.each do |event|
  puts event
  case event.type
  when :text
    ;
  when :command
    ;
  when :option
    ;
  when :subnegotiation
    ;
  when :error
    ;
  else
    raise "Unknown event type: #{event.type}"
  end
end
