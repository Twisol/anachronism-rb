require "ffi"

module Anachronism::Native
  extend FFI::Library
  ffi_lib 'anachronism'
  
  typedef :pointer, :parser
  typedef :pointer, :nvt
  typedef :pointer, :channel
  
  enum :error, [
    :registered, -8,
    :not_open,
    :bad_channel,
    :bad_parser,
    :bad_nvt,
    :invalid_option,
    :invalid_command,
    :subnegotiating,
    :alloc,
    :ok,
    :interrupt,
  ]
  
  enum :event_type, [
    :data,
    :command,
    :option,
    :subnegotiation,
    :warning,
    :send,
  ]
  
  enum :channel_provider, [
    :local,
    :remote,
  ]
  
  enum :channel_mode, [
    :off,
    :on,
    :lazy,
  ]
  
  enum :channel_event_type, [
    :begin,
    :end,
    :data,
  ]
  
  callback :parser_callback, [:parser, :pointer], :void
  callback :event_callback, [:nvt, :pointer], :void
  callback :channel_toggle_callback, [:channel, :channel_mode, :channel_provider], :void
  callback :channel_data_callback, [:channel, :channel_event_type, :pointer, :size_t], :void
  
  class Event < FFI::Struct
    layout(
      :type, :event_type
    )
  end
  
  class DataEvent < FFI::Struct
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
  
  class SendEvent < FFI::Struct
    layout(
      :SUPER_, Event,
      :data, :pointer,
      :length, :size_t
    )
  end
  
  class InterruptCode < FFI::Struct
    layout(
      :source, :short,
      :code, :char
    )
  end
  
  # Parser
  attach_function :new_parser, :telnet_parser_new, [:parser_callback, :pointer], :parser
  attach_function :free_parser, :telnet_parser_free, [:parser], :void
  
  attach_function :parser_get_userdata, :telnet_parser_get_userdata, [:parser, :pointer], :error
  
  attach_function :parser_parse, :telnet_parser_parse, [:parser, :buffer_in, :size_t, :pointer], :error
  attach_function :parser_interrupt, :telnet_parser_interrupt, [:parser], :error
  
  # NVT
  attach_function :new_nvt, :telnet_nvt_new, [:event_callback, :pointer], :nvt
  attach_function :free_nvt, :telnet_nvt_free, [:nvt], :void
  
  attach_function :get_userdata, :telnet_get_userdata, [:nvt, :pointer], :error
  
  attach_function :recv, :telnet_recv, [:nvt, :buffer_in, :size_t, :pointer], :error
  attach_function :interrupt, :telnet_interrupt, [:nvt, InterruptCode], :error
  attach_function :get_last_interrupt, :telnet_get_last_interrupt, [:nvt, :pointer], :error
  
  attach_function :send_data, :telnet_send_data, [:nvt, :buffer_in, :size_t], :error
  attach_function :send_command, :telnet_send_command, [:nvt, :uchar], :error
  attach_function :send_option, :telnet_send_option, [:nvt, :uchar, :uchar], :error
  attach_function :send_subnegotiation_start, :telnet_send_subnegotiation_start, [:nvt, :uchar], :error
  attach_function :send_subnegotiation_end, :telnet_send_subnegotiation_end, [:nvt], :error
  attach_function :send_subnegotiation, :telnet_send_subnegotiation, [:nvt, :uchar, :buffer_in, :size_t], :error
  
  # Channel
  attach_function :new_channel, :telnet_channel_new, [:channel_toggle_callback, :channel_data_callback, :pointer], :channel
  attach_function :free_channel, :telnet_channel_free, [:channel], :void
  
  attach_function :register_channel, :telnet_channel_register, [:channel, :nvt, :short, :channel_mode, :channel_mode], :error
  attach_function :unregister_channel, :telnet_channel_unregister, [:channel], :error
  
  attach_function :channel_get_userdata, :telnet_channel_get_userdata, [:channel, :pointer], :error
  attach_function :channel_get_nvt, :telnet_channel_get_nvt, [:channel, :pointer], :error
  attach_function :channel_get_option, :telnet_channel_get_option, [:channel, :pointer], :error
  attach_function :channel_get_status, :telnet_channel_get_status, [:channel, :channel_provider, :pointer], :error
  
  attach_function :channel_send, :telnet_channel_send, [:channel, :pointer, :size_t], :error
  
  # IAC symbol translation
  SYM2CMD = {}
  CMD2SYM = {}
  
  [
   :SE,   :NOP, :DM,   :BRK,
   :IP,   :AO,  :AYT,  :EC,
   :EL,   :GA,  :SB,   :WILL,
   :WONT, :DO,  :DONT, :IAC,
  ].each_with_index do |sym, i|
    CMD2SYM[240+i] = sym
    SYM2CMD[sym] = 240+i
  end
  
  def self.command_to_sym (num)
    CMD2SYM[num]
  end
  
  def self.sym_to_command (sym)
    SYM2CMD[sym]
  end
end
