require 'anachronism/version'

module Anachronism
  class Parser
    def out (&blk)
      @out = blk
    end
    
    def process (data)
      events = process_internal(data)
      if block_given?
        events.each do |event|
          yield event
        end
      end
      events
    end
    
    # Emit a WILL, WONT, DO, or DONT option request.
    def send_option (command, option)
      option = option.to_i
      unless (0..255).include?(option)
        raise "Option code must be within (0..255)"
      end
      
      command = case command
        when :will then 250
        when :wont then 251
        when :do   then 252
        when :dont then 253
      else
        raise "Invalid command (must be :will, :wont, :do, or :dont)"
      end.chr
      
      emit "\xFF#{command}#{option}"
    end
    
  private
    def emit (data)
      @out.call(data) if @out
      data
    end
  end
end

# Pull in the C extension implementation
require 'anachronism/anachronism'
