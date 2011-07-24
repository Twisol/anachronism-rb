class Anachronism::Channel
  attr_reader :telnet, :telopt
  
  def initialize (telopt, telnet)
    telnet.bind(telopt, self)
    
    @telnet = telnet
    @telopt = telopt
  end
  
  def send (data)
    @telnet.send_subnegotiation(@telopt, data)
  end
  
  
  def request_remote_enable (opts={})
    @telnet.request_remote_enable(@telopt, opts)
  end
  
  def request_remote_disable
    @telnet.request_remote_disable(@telopt)
  end
  
  def request_local_enable (opts={})
    @telnet.request_local_enable(@telopt, opts)
  end
  
  def request_local_disable
    @telnet.request_local_disable(@telopt)
  end
  
  
  def local_enabled?
    @telnet.local_enabled?(@telopt)
  end
  
  def remote_enabled?
    @telnet.remote_enabled?(@telopt)
  end
  
  
  #
  # Callbacks
  ##
  def on_focus
  end
  
  def on_blur
  end
  
  def on_text (text)
  end
  
  def on_local_toggle (active)
  end
  
  def on_remote_toggle (active)
  end
end
