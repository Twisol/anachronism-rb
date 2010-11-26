Bundler.setup
require 'anachronism'

describe Anachronism::Parser do
  def collect_events (data)
    arr = []
    @parser.process(data) {|type,| arr << type}
    yield arr if block_given?
    arr
  end
  
  before :each do
    @parser = Anachronism::Parser.new
    @parser.out {|data| puts "Data out: #{data}"}
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
      fail events.to_s unless events == [:subnegotiation]
    end
  end
  
  it "resumes properly between two packets" do
    collect_events "\xFF" do |events|
      fail events.tO_s unless events == []
    end
    collect_events "\xFF" do |events|
      fail events.to_s unless events == [:text]
    end
  end
end
