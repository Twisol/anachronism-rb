require "ffi"

module Anachronism::Native
  extend FFI::Library
  ffi_lib 'anachronism'
  
  typedef :pointer, :nvt
  typedef :uchar, :telopt
  
  enum :error, [
    :bad_parser, -3,
    :bad_nvt,
    :invalid_command,
    :alloc,
    :ok,
    :interrupt,
  ]
  
  enum :telopt_mode, [
    :off,
    :on,
    :lazy,
  ]
  
  enum :telopt_location, [
    :local,
    :remote
  ]
  
  
  #
  # NVT Events
  ##
  enum :nvt_event_type, [
    :data,
    :command,
    :warning,
    :send,
  ]
  
  class Event < FFI::Struct
    layout(
      :type, :nvt_event_type
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
  
  #
  # Telopt Events
  ##
  enum :telopt_event_type, [
    :toggle,
    :focus,
    :data,
  ]
  
  class TeloptEvent < FFI::Struct
    layout(
      :type, :telopt_event_type
    )
  end
  
  class ToggleTeloptEvent < FFI::Struct
    layout(
      :SUPER_, TeloptEvent,
      :where, :telopt_location,
      :status, :telopt_mode
    )
  end
  
  class FocusTeloptEvent < FFI::Struct
    layout(
      :SUPER_, TeloptEvent,
      :focus, :uchar
    )
  end
  
  class DataTeloptEvent < FFI::Struct
    layout(
      :SUPER_, TeloptEvent,
      :data, :pointer,
      :length, :size_t
    )
  end
  
  
  # Event callbacks
  callback :nvt_event_callback, [:nvt, :pointer], :void
  callback :telopt_event_callback, [:nvt, :telopt, :pointer], :void
  
  # NVT
  attach_function :new_nvt,  :telnet_nvt_new,  [:nvt_event_callback, :telopt_event_callback, :pointer], :nvt
  attach_function :free_nvt, :telnet_nvt_free, [:nvt], :void
  
  attach_function :get_userdata, :telnet_get_userdata, [:nvt, :pointer], :error
  attach_function :interrupt,    :telnet_interrupt,    [:nvt],           :error
  
  attach_function :receive,             :telnet_receive,             [:nvt, :buffer_in, :size_t, :pointer], :error
  attach_function :send_data,           :telnet_send_data,           [:nvt, :buffer_in, :size_t],           :error
  attach_function :send_command,        :telnet_send_command,        [:nvt, :uchar],                        :error
  attach_function :send_subnegotiation, :telnet_send_subnegotiation, [:nvt, :telopt, :buffer_in, :size_t],  :error
  
  attach_function :telopt_enable_local,   :telnet_telopt_enable_local,   [:nvt, :telopt, :uchar],   :error
  attach_function :telopt_enable_remote,  :telnet_telopt_enable_remote,  [:nvt, :telopt, :uchar],   :error
  attach_function :telopt_disable_local,  :telnet_telopt_disable_local,  [:nvt, :telopt],           :error
  attach_function :telopt_disable_remote, :telnet_telopt_disable_remote, [:nvt, :telopt],           :error
  attach_function :telopt_status_local,   :telnet_telopt_status_local,   [:nvt, :telopt, :pointer], :error
  attach_function :telopt_status_remote,  :telnet_telopt_status_remote,  [:nvt, :telopt, :pointer], :error
end
