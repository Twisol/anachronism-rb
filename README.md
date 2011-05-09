# Anachronism

Anachonism implements a simple interface to the [libanachronism][1] Telnet library,
allowing Ruby programs to utilize the Telnet protocol effectively. I wrote it
for use in my MUD client project, but it is generic enough for most
Telnet-based applications.

## Example

    require "anachronism"
    
    class ExampleNVT < Anachronism::NVT
      # Hook for data to be sent to a remote server
      def on_send (data)
        puts "OUT: #{data}"
      end
      
      # Hook for incoming textual data
      def on_data (data)
        puts "IN: #{data}"
      end
    end
    
    nvt = ExampleNVT.new
    nvt.receive "incoming data"
    nvt.send_data "outgoing data"
    nvt.send_command :AYT

[1]: https://github.com/Twisol/anachronism
