Bundler.setup
require 'anachronism'

describe Anachronism::NVT do
  def collect_events (data)
    arr = []
    @nvt.process(data) {|type, data| arr << type}
    yield arr if block_given?
    arr
  end
  
  before :each do
    @nvt = Anachronism::NVT.new
  end
  
  it "emits no events if nothing is given" do
    collect_events "" do |events|
      fail events.to_s unless events == []
    end
  end
  
  it "emits a text event" do
    collect_events "foobarbaz" do |events|
      fail events.to_s unless events == [:text]
    end
  end
  
  it "emits a command event" do
    collect_events "\xFF\xF1" do |events|
      fail events.to_s unless events == [:command]
    end
  end
  
  it "emits an option event" do
    collect_events "\xFF\xFD\xFF" do |events|
      fail events.to_s unless events == [:option]
    end
  end
  
  it "emits a subnegotiation event" do
    collect_events "\xFF\xFA\xFFfoobar\xFF\xF0" do |events|
      fail events.to_s unless events == [:subnegotiation, :text, :subnegotiation]
    end
  end
  
  it "resumes properly between two packets" do
    collect_events "\xFF" do |events|
      fail events.to_s unless events == []
    end
    collect_events "\xFF" do |events|
      fail events.to_s unless events == [:text]
    end
  end
  
  it "splits text events around errors" do
    collect_events "a\rb" do |events|
      fail events.to_s unless events == [:text, :error, :text]
    end
  end
  
  it "sends text" do
    @nvt.out do |data|
      fail data unless data == "foo\xFF\xFFbar\r\0baz\r\n"
    end
    @nvt.send_text "foo\xFFbar\rbaz\n"
  end
  
  it "sends a command" do
    @nvt.out do |data|
      fail data.bytes.to_a.to_s unless data == "\xFF#{Anachronism::COMMANDS[:AYT].chr}"
    end
    @nvt.send_command :AYT
  end
  
  it "sends an option" do
    @nvt.out do |data|
      fail data.bytes.to_a.to_s unless data == "\xFF\xFE\xFF"
    end
    @nvt.dont_option 255
  end
  
  it "can halt in the middle of processing" do
    data = @nvt.process("\xFF\xF2foo") do |type, data|
      fail type.to_s unless type == :command
      @nvt.halt
    end
    fail data.to_s unless data == "foo"
  end
end
