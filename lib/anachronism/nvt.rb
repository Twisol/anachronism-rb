module Anachronism
  class NVT
    def initialize (receiver)
      @nvt = Anachronism::Native.new(receiver)
    end
    
    def recv (data)
      bytes_used = @nvt.recv(data)
      data[bytes_used..-1]
    end
    
    def send_text (data)
      @nvt.send_text(data)
    end
    
    def send_command (command)
      command = Anachronism::COMMANDS[command] if command.is_a? Symbol
      @nvt.send_command(command)
    end
    
    def send_option (command, option)
      command = Anachronism::COMMANDS[command] if command.is_a? Symbol
      @nvt.send_option(command, option)
    end
    
    def send_subnegotiation (option, data)
      @nvt.send_subnegotiation(option, data)
    end
    
    def halt
      @nvt.halt
    end
  end
end