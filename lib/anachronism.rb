require 'anachronism/version'
require 'anachronism/anachronism'

module Anachronism
  class Parser
    def out (&blk)
      @out = blk
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
      
      emit "\xFF#{command}#{option.chr}"
    end
    
    def send_text (text)
      emit text.gsub("\r", "\r\0").gsub("\r\0\n", "\r\n").gsub("\xFF", "\xFF\xFF")
    end
    
  private
    def emit (data)
      data = data.force_encoding("ASCII-8BIT")
      @out.call(data) if @out
      data
    end
  end
end
