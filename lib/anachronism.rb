require 'anachronism/version'
require 'anachronism/anachronism'

module Anachronism
  Event = Struct.new(:type, :data)
  
  class NVT
    def out (&blk)
      @out = blk
    end
    
    # Emit a WILL, WONT, DO, or DONT option request.
    def send_option (command, option)
      option = option[0]
      unless (0..255).include?(option.ord)
        raise "Option code must be within (0..255)"
      end
      
      command = case command
        when :will then 251
        when :wont then 252
        when :do   then 253
        when :dont then 254
      else
        raise "Invalid command (must be :will, :wont, :do, or :dont)"
      end.chr
      
      emit "\xFF#{command}#{option}"
    end
    
    def send_text (text)
      text = text.gsub("\r", "\r\0")
      text.gsub!("\r\0\n", "\r\n")
      text.gsub!("\xFF", "\xFF\xFF")
      emit text
    end
    
  private
    def emit (data)
      data = data.force_encoding("ASCII-8BIT")
      @out.call(data) if @out
      data
    end
  end
end
