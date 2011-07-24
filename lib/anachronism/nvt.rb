class Anachronism::Telnet
  def initialize
    # Make sure these aren't GC'd while the object exists.
    @_on_nvt_event = proc {|_, ev| process_nvt_event(ev)}
    @_on_telopt_event = proc {|_, telopt, ev| process_telopt_event(telopt, ev)}
    
    @telnet_nvt = Anachronism::Native.new_nvt(
      @_on_nvt_event,
      @_on_telopt_event,
      FFI::Pointer.new(0))
    raise NoMemoryError if @telnet_nvt == FFI::Pointer.new(0)
    @telopt_callbacks = Array.new(256)
  end
  
  def receive (data)
    ptr = FFI::MemoryPointer.new :pointer
    err = Anachronism::Native.receive(@telnet_nvt, data, data.length, ptr)
    raise NoMemoryError if err == :alloc
    data[ptr.read_int..-1]
  end
  
  # Halts the Telnet parser at the current point, usually so the remainder of
  # the data can be preprocessed before continuing.
  def interrupt_parser
    Anachronism::Native.interrupt(@telnet_nvt)
    nil
  end
  
  
  def send_text (data)
    err = Anachronism::Native.send_data(@telnet_nvt, data, data.length)
    raise NoMemoryError if err == :alloc
  end
  
  def send_command (command)
    err = Anachronism::Native.send_command(@telnet_nvt, command)
    raise ArgumentError, "#{command} is not a valid single-byte command" if err == :invalid_command
  end
  
  def send_subnegotiation (telopt, data)
    err = Anachronism::Native.send_subnegotiation(@telnet_nvt, telopt, data, data.length)
    raise NoMemoryError if err == :alloc
  end
  
  
  def request_local_enable (telopt, opts={})
    Anachronism::Native.telopt_enable_local(@telnet_nvt, telopt, (opts[:lazy]) ? 1 : 0)
    nil
  end
  
  def request_local_disable (telopt)
    Anachronism::Native.telopt_disable_local(@telnet_nvt, telopt)
    nil
  end
  
  def request_remote_enable (telopt, opts={})
    Anachronism::Native.telopt_enable_remote(@telnet_nvt, telopt, (opts[:lazy]) ? 1 : 0)
    nil
  end
  
  def request_remote_disable (telopt)
    Anachronism::Native.telopt_disable_remote(@telnet_nvt, telopt)
    nil
  end
  
  
  def remote_enabled? (telopt)
    ptr = FFI::MemoryPointer.new :int
    Anachronism::Native.telopt_status_local(@telnet_nvt, telopt, ptr)
    !!ptr.read_int
  end
  
  def local_enabled? (telopt)
    ptr = FFI::MemoryPointer.new :int
    Anachronism::Native.telopt_status_remote(@telnet_nvt, telopt, ptr)
    !!ptr.read_int
  end
  
  
  def bind (telopt, receiver)
    raise "Can't bind to a bound telopt." if @telopt_callbacks[telopt]
    @telopt_callbacks[telopt] = receiver
  end
  
  def unbind (telopt)
    @telopt_callbacks[telopt] = nil
  end
  
  
  #
  # Callbacks
  ##
  def on_text (text)
  end
  
  def on_command (command)
  end
  
  def on_send (data)
  end
  
  def on_warning (message, position)
  end
  

  def process_nvt_event (event_ptr) # :nodoc:
    ev = Anachronism::Native::Event.new(event_ptr)
    
    case ev[:type]
    when :data
      ev = Anachronism::Native::DataEvent.new(event_ptr)
      on_text ev[:data].read_string(ev[:length])
    when :command
      ev = Anachronism::Native::CommandEvent.new(event_ptr)
      on_command ev[:command]
    when :send
      ev = Anachronism::Native::SendEvent.new(event_ptr)
      on_send ev[:data].read_string(ev[:length])
    when :warning
      ev = Anachronism::Native::WarningEvent.new(event_ptr)
      on_warning ev[:message], ev[:position]
    end
  end
  
  def process_telopt_event (telopt, event_ptr) # :nodoc:
    receiver = @telopt_callbacks[telopt]
    return unless receiver
    
    ev = Anachronism::Native::TeloptEvent.new(event_ptr)
    case ev[:type]
    when :toggle
      ev = Anachronism::Native::ToggleTeloptEvent.new(event_ptr)
      if ev[:where] == :local
        receiver.on_local_toggle(ev[:status] == :on)
      elsif ev[:where] == :remote
        receiver.on_remote_toggle(ev[:status] == :on)
      end
    when :focus
      ev = Anachronism::Native::FocusTeloptEvent.new(event_ptr)
      if ev[:focus] == 0
        receiver.on_blur
      else
        receiver.on_focus
      end
    when :data
      ev = Anachronism::Native::DataTeloptEvent.new(event_ptr)
      receiver.on_text ev[:data].read_string(ev[:length])
    end
  end
end
