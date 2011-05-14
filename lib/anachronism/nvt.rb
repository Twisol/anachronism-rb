module Anachronism
  class Error < ::Exception; end
  
  class CommandError < Error; end
  class OptionError < Error; end
  class AllocationError < Error; end
  class SubnegotiationError < Error; end
  
  class RegisteredError < Error; end
  class ChannelClosedError < Error; end
end

class Anachronism::NVT
  # Finalizer
  def self.finalize (nvt)
    Proc.new do
      Anachronism::Native.free_nvt(nvt)
    end
  end
  
  def initialize
    # for GC prevention
    @_nogc = []
    @_channels = []
    
    @_nogc << on_event = proc{|nvt, event| process_event(event)}
    @nvt = Anachronism::Native.new_nvt(on_event, FFI::Pointer.new(0))
    
    @halt_reason = nil
    
    # Make sure to free the NVT and router on GC
    ObjectSpace.define_finalizer(self, self.class.finalize(@nvt))
  end
  
  def interrupt (source, reason)
    code = Anachronism::Native::InterruptCode.new
    code[:source] = source
    code[:code] = reason
    Anachronism::Native.interrupt(@nvt, code)
    nil
  end
  
  def last_interrupt_code
    ptr = FFI::MemoryPointer.new :pointer
    Anachronism::Native.get_last_interrupt(@nvt, ptr)
    code = Anachronism::Native::InterruptCode.new(ptr.read_pointer)
    [code[:source], code[:code]]
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
    num = Anachronism::Native.sym_to_command(command)
    status = Anachronism::Native.send_command(@nvt, num)
    if status == :bad_command
      raise Anachronism::CommandError, "Invalid command '#{command}'."
    elsif status == :subnegotiating
      raise Anachronism::SubnegotiationError, "Cannot send command '#{command}' during subnegotiation."
    end
    nil
  end
  
  def send_option (command, option)
    num = Anachronism::Native.sym_to_command(command)
    status = Anachronism::Native.send_option(@nvt, num, option)
    if status == :bad_command
      raise Anachronism::CommandError, "Invalid command '#{command}'."
    elsif status == :subnegotiating
      raise Anachronism::SubnegotiationError, "Cannot send command '#{command}' during subnegotiation."
    end
    nil
  end
  
  def send_subnegotiation_start (option)
    status = Anachronism::Native.send_subnegotiation_start(@nvt, option)
    if status == :subnegotiating
      raise Anachronism::SubnegotiationError, "Already subnegotiating."
    end
    nil
  end
  
  def send_subnegotiation_end (option)
    status = Anachronism::Native.send_subnegotiation_end(@nvt, option)
    if status == :subnegotiating
      raise Anachronism::SubnegotiationError, "Not subnegotiating."
    end
    nil
  end
  
  def send_subnegotiation (option, data)
    status = Anachronism::Native.send_subnegotiation(@nvt, option, data, data.length)
    if status == :allocation
      raise Anachronism::AllocationError, "Unable to allocate buffer for outgoing Telnet data."
    elsif status == :subnegotiating
      raise Anachronism::SubnegotiationError, "Already subnegotiating."
    end
    nil
  end
  
  def register_channel (channel, option, modes={})
    mapping = {true => :on, false => :off, :lazy => :lazy}
    local = mapping[modes[:local]] || :off
    remote = mapping[modes[:remote]] || :off
    
    option = -1 if option == :main
    status = Anachronism::Native.register_channel(channel, @nvt, option, local, remote)
    if status == :registered
      raise Anachronism::RegisteredError, "Channel already registered."
    elsif status == :invalid_option
      raise Anachronism::OptionError, "Option out of range: #{option}."
    end

    nil
  end
  
  def unregister_channel (channel)
    Anachronism::Native.unregister_channel(channel)
  end
  
protected
  def process_event (event_ptr)
    ev = Anachronism::Native::Event.new(event_ptr)
    
    case ev[:type]
    when :data
      ev = Anachronism::Native::DataEvent.new(event_ptr)
      data = ev[:data].read_string(ev[:length])
      on_data data
    when :option
      ev = Anachronism::Native::OptionEvent.new(event_ptr)
      command = Anachronism::Native.command_to_sym(ev[:command]) || ev[:command]
      on_option command, ev[:option]
    when :subnegotiation
      ev = Anachronism::Native::SubnegotiationEvent.new(event_ptr)
      on_subnegotiation (ev[:active] == 1), ev[:option]
    when :command
      ev = Anachronism::Native::CommandEvent.new(event_ptr)
      command = Anachronism::Native.command_to_sym(ev[:command]) || ev[:command]
      on_command command
    when :warning
      ev = Anachronism::Native::WarningEvent.new(event_ptr)
      on_warning ev[:message], ev[:position]
    when :send
      ev = Anachronism::Native::SendEvent.new(event_ptr)
      on_send ev[:data].read_string(ev[:length])
    end
  end
  
  # Callbacks
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
end
