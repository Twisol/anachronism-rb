require 'anachronism/anachronism'

module Anachronism
  Event = Struct.new(:type, :data)
  
  class NVT
    def out (&blk)
      @out = blk
    end
    
    def will_option (option)
      send_option(251, option)
    end
    
    def wont_option (option)
      send_option(252, option)
    end
    
    def do_option (option)
      send_option(253, option)
    end
    
    def dont_option (option)
      send_option(254, option)
    end
  
  private
    def send_option (command, option)
      unless (0..255).include?(option.ord)
        raise "Option code must be within (0..255)"
      end
      
      emit "\xFF#{command.chr}#{option.chr}"
    end
    
    def emit (data)
      data = data.force_encoding("ASCII-8BIT")
      @out.call(data) if @out
      data
    end
  end
end
