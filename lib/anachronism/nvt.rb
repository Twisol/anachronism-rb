module Anachronism
  Event = Struct.new(:type, :data)
  
  class NVT
    class Callbacks
      attr_reader :nvt
      
      def initialize (nvt)
        @nvt = nvt
      end
      
      def on_text (text)
        nvt.receive :text, text
      end
      
      def on_command (command)
        nvt.receive :command, command
      end
      
      def on_option (option, command)
        nvt.receive :option, option, command
      end
      
      def on_mode (mode, extra)
        nvt.receive :mode, mode, extra
      end
      
      def on_error (fatal, message, position)
        nvt.receive :error, fatal, message, position
      end
      
      def on_send (data)
        nvt.emit data
      end
    end
    
    def initialize
      @nvt = Anachronism::Native.new(Callbacks.new(self))
    end
    
    def out (&blk)
      @out = blk
    end
    
    def process (data, &blk)
      @receiver = blk
      bytes_used = @nvt.process(data)
      @receiver = nil
      
      data[bytes_used..-1]
    end
    
    def send_text (data)
      @nvt.send_text(data)
    end
    
    def send_command (command)
      @nvt.send_command(command)
    end
    
    def halt
      @nvt.halt
    end
    
    def receive (type, *args)
      @receiver.call(type, args) if @receiver
    end
    
    def emit (data)
      data = data.force_encoding("ASCII-8BIT")
      @out.call(data) if @out
      data
    end
    
  private
    def send_option (command, option)
      unless (0..255).include?(option.ord)
        raise "Option code must be within (0..255)"
      end
      
      emit "\xFF#{command.chr}#{option.chr}"
    end
  end
end