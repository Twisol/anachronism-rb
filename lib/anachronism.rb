require 'telnet_parser'

module Anachronism
  VERSION = "0.0.1"
end
  
  Event = Struct.new('Event', :type, :data)
  
  class Parser
    def process (data)
      [Event.new(:text, data)]
    end
  end
end

telnet = Anachronism::Parser.new
events = telnet.process("text")
events.each do |event|
  case event.type
  when :text
    puts event.data
  when :command
    ;
  when :option
    ;
  when :subnegotiation
    ;
  else
    raise "Unknown event type: #{event.type}"
  end
end
