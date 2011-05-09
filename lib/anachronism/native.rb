module Anachronism::Native
  extend FFI::Library
  ffi_lib 'anachronism'
  
  typedef :pointer, :nvt
  typedef :pointer, :callbacks
  
  enum :telnet_error, [
    :bad_nvt,       -3,
    :bad_command,
    :subnegotiating,
    :allocation,
    :ok,
  ]
  
  enum :telnet_event_type, [
    :data,
    :command,
    :option,
    :subnegotiation,
    :warning,
  ]
  
  enum :telnet_command, [
    :NOP, 241,
    :DM,
    :BRK,
    :IP,
    :AO,
    :AYT,
    :EC,
    :EL,
    :GA,
    :SB,
  ]
  
  enum :telnet_option_mode, [
    :WILL, 251,
    :WONT,
    :DO,
    :DONT,
  ]
  
  callback :recv_callback, [:nvt, :pointer], :void
  callback :send_callback, [:nvt, :pointer, :size_t], :void
  
  class Event < FFI::Struct
    layout(
      :type, :telnet_event_type
    )
  end
  
  class TextEvent < FFI::Struct
    layout(
      :SUPER_, Event,
      :data, :pointer,
      :length, :size_t
    )
  end
  
  class CommandEvent < FFI::Struct
    layout(
      :SUPER_, Event,
      :command, :uchar
    )
  end
  
  class OptionEvent < FFI::Struct
    layout(
      :SUPER_, Event,
      :command, :uchar,
      :option, :uchar
    )
  end
  
  class SubnegotiationEvent < FFI::Struct
    layout(
      :SUPER_, Event,
      :active, :int,
      :option, :uchar
    )
  end
  
  class WarningEvent < FFI::Struct
    layout(
      :SUPER_, Event,
      :message, :string,
      :position, :size_t
    )
  end
  
  
  class Callbacks < FFI::Struct
    layout(
      :on_recv, :recv_callback,
      :on_send, :send_callback
    )
  end
  
  attach_function :new_nvt, :telnet_new_nvt, [], :nvt
  attach_function :free_nvt, :telnet_free_nvt, [:nvt], :void
  
  attach_function :get_callbacks, :telnet_get_callbacks, [:nvt, :callbacks], :telnet_error
  
  attach_function :get_userdata, :telnet_get_userdata, [:nvt, :pointer], :telnet_error
  attach_function :set_userdata, :telnet_set_userdata, [:nvt, :pointer], :telnet_error
  
  attach_function :halt, :telnet_halt, [:nvt], :telnet_error
  attach_function :recv, :telnet_recv, [:nvt, :buffer_in, :size_t, :pointer], :telnet_error
  
  attach_function :send_data, :telnet_send_data, [:nvt, :buffer_in, :size_t], :telnet_error
  attach_function :send_command, :telnet_send_command, [:nvt, :telnet_command], :telnet_error
  attach_function :send_option, :telnet_send_option, [:nvt, :telnet_option_mode, :uchar], :telnet_error
  attach_function :send_subnegotiation_start, :telnet_send_subnegotiation_start, [:nvt, :uchar], :telnet_error
  attach_function :send_subnegotiation_end, :telnet_send_subnegotiation_end, [:nvt], :telnet_error
  attach_function :send_subnegotiation, :telnet_send_subnegotiation, [:nvt, :uchar, :buffer_in, :size_t], :telnet_error
end
