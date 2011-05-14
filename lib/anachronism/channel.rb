class Anachronism::Channel
  attr_reader :nvt
  
  NOGC = {} # :nodoc:
  
  def self.finalize (channel)
    Proc.new do
      Anachronism::Native.free_channel(channel)
    end
  end
  
  def initialize
    @_nogc = []
    
    @_nogc << on_toggle = proc {|channel, *a| process_toggle(*a)}
    @_nogc << on_data = proc {|channel, *a| process_data(*a)}
    
    @channel = Anachronism::Native.new_channel(on_toggle, on_data, FFI::Pointer.new(0))
    
    ObjectSpace.define_finalizer(self, self.class.finalize(@channel))
  end
  
  def register (nvt, option, modes={})
    NOGC[@channel] = self
    nvt.register_channel(@channel, option, modes)
    @nvt = nvt
    nil
  end
  
  def unregister
    NOGC.delete(@channel)
    @nvt.unregister_channel(@channel)
    @nvt = nil
    nil
  end
  
  def send (data)
    status = Anachronism::Native.channel_send(@channel, data, data.length)
    if status == :not_open
      raise Anachronism::ChannelClosedError, "The channel is not open."
    elsif status == :subnegotiating
      raise Anachronism::SubnegotiationError, "A subnegotiation is in progress."
    elsif status == :alloc
      raise Anachronism::AllocationError, "Unable to allocate buffer for outgoing data."
    end
    nil
  end
  
  def enable (where, lazy)
    status = Anachronism::Native.channel_toggle(@channel, where, lazy ? :lazy : :on)
    if status == :registered
      raise Anachronism::RegisteredError, "The channel is not registered with an NVT."
    end
    nil
  end
  
  def disable (where)
    status = Anachronism::Native.channel_toggle(@channel, where, :off)
    if status == :registered
      raise Anachronism::RegisteredError, "The channel is not registered with an NVT."
    end
    nil
  end
  
  def option
    ptr = FFI::MemoryPointer.new :short
    status = Anachronism::Native.channel_get_option(@channel, ptr)
    return nil if status == :registered
    
    opt = ptr.read_short
    if opt == -1
      :main
    else
      opt
    end
  end
  
  def enabled? (where)
    ptr = FFI::MemoryPointer.new :int
    status = Anachronism::Native.channel_get_status(@channel, where, ptr)
    !!ptr.read_int
  end
  
protected
  def process_toggle (on, who)
    if on
      on_open(who)
    else
      on_close(who)
    end
  end
  
  def process_data (type, data, length)
    if type == :begin
      on_focus
    elsif type == :end
      on_blur
    elsif type == :data
      on_data(data.read_string(length))
    end
  end
  
  
  def on_open (who)
  end
  
  def on_close (who)
  end
  
  def on_focus
  end
  
  def on_blur
  end
  
  def on_data (data)
  end
end
