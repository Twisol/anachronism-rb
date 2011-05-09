class Anachronism::Error < Exception; end
class Anachronism::CommandError < Exception; end
class Anachronism::AllocationError < Exception; end
class Anachronism::SubnegotiationError < Exception; end

class Anachronism::NVT
  # Finalizer
  def self.finalize (nvt)
    Proc.new {Anachronism::Native.free_nvt(nvt)}
  end
  
  def initialize
    @nvt = Anachronism::Native.new_nvt 
    
    ptr = FFI::MemoryPointer.new :pointer
    Anachronism::Native.get_callbacks(@nvt, ptr)
    callbacks = Anachronism::Native::Callbacks.new(ptr.get_pointer(0))
    
    callbacks[:on_recv] = proc {|nvt, event| process_recv(event)}
    callbacks[:on_send] = proc {|nvt, data, length| process_send(data, length)}
    
    ObjectSpace.define_finalizer(self, self.class.finalize(@nvt))
  end
  
  def halt
    Anachronism::Native.halt(@nvt)
    nil
  end
  
  def receive (data)
    ptr = FFI::MemoryPointer.new :pointer
    status = Anachronism::Native.recv(@nvt, data, data.length, ptr)
    if status == :allocation
      raise Anachronism::AllocationError, "Unable to allocate buffer for incoming Telnet data."
    end
    ptr.read_int
  end
  
  def send_data (data)
    status = Anachronism::Native.send_data(@nvt, data, data.length)
    if status == :allocation
      raise Anachronism::AllocationError, "Unable to allocate buffer for outgoing Telnet data."
    end
    nil
  end
  
  def send_command (command)
    status = Anachronism::Native.send_command(@nvt, command)
    if status == :bad_command
      raise Anachronism::CommandError, "Invalid command '#{command}'."
    elsif status == :subnegotiating
      raise Anachronism::SubnegotiationError, "Cannot send command '#{command}' during subnegotiation."
    end
    nil
  end
  
  # Overridable event hooks
  def on_data (data)
  end
  
  def on_command (command)
  end
  
  def on_option (command, option)
  end
  
  def on_subnegotiation (active, option)
  end
  
  def on_warning (message, position)
  end
  
  def on_send (data)
  end
  #~
  
protected
  def process_recv (event_ptr)
    event = Anachronism::Native::Event.new(event_ptr)
    case event[:type]
    when :data
      event = Anachronism::Native::TextEvent.new(event_ptr)
      on_data(event[:data].read_string(event[:length]))
    when :command
      event = Anachronism::Native::CommandEvent.new(event_ptr)
      on_command(event[:command])
    when :option
      event = Anachronism::Native::OptionEvent.new(event_ptr)
      on_option(event[:command], event[:option])
    when :subnegotiation
      event = Anachronism::Native::SubnegotiationEvent.new(event_ptr)
      on_subnegotiation(event[:active] == 1, event[:option])
    when :warning
      event = Anachronism::Native::WarningEvent.new(event_ptr)
      on_warning(event[:data].read_string_to_null, event[:position])
    end
  end
  
  def process_send (data, length)
    on_send(data.read_string(length))
  end
end
