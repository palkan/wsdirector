require "spec_helper"
require 'websocket-client-simple'
require 'json'

describe WSdirector::Websocket do
  let(:ws_addr) { 'ws://localhost:9876' }
  let(:ws) { WSdirector::Websocket.new(ws_addr) }
  let(:fake_double) { double }

  it 'assign receive queue' do
    expect(ws.receive_queue).to eq([])
  end
  it 'assign ws server address' do
    expect(ws.addr).to eq(ws_addr)
  end

  describe '#init' do
    before(:example) do
      allow(WebSocket::Client::Simple).to receive(:connect).and_return(fake_double)
      allow(fake_double).to receive(:on)
    end
    it 'connect to server' do
      expect(WebSocket::Client::Simple).to receive(:connect).with(ws_addr, headers: { origin: 'http://localhost:9876' })
      ws.init
    end

    it 'assign web_socket_client' do
      ws.init
      expect(ws.websocket_client).to eq(fake_double)
    end
  end

  describe '#receive' do
    it 'return expected result' do
      ws.receive_queue = ['a', 'b', 'c']
      expect(ws.receive([nil, nil])).to eq(['a', 'b'])
    end
  end

  describe '#send_receive' do
    before(:example) { ws.receive_queue = ['a', 'b', 'c'] }
    it 'send message' do
      allow(ws).to receive(:websocket_client).and_return(fake_double)
      expect(fake_double).to receive(:send)
      ws.send_receive('command', [nil, nil])
    end
    it 'return expected result' do
      allow(ws).to receive_message_chain(:websocket_client, :send)
      expect(ws.send_receive('command', [nil, nil, nil])).to eq(['a', 'b', 'c'])
    end
  end

  describe '#parse_message' do
    it 'return JSON generated mess if i call it with hash with key data' do
      message = { 'data' => { "some" => "message" } }
      expect(ws.parse_message(message)).to eq(JSON.generate(message))
    end
    it "return same message if there is no data or it's not a hash" do
      message = 'message'
      expect(ws.parse_message(message)).to eq(message)
    end
  end
end
