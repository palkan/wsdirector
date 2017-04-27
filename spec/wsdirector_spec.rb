require "spec_helper"
require_relative 'echo_server'

describe WSdirector do

  before(:context) do
    Thread.new { WSdirector::EchoServer.start }
  end

  it "has a version number" do
    expect(WSdirector::VERSION).not_to be nil
  end

  describe 'connect to websocket server' do
    context 'when connection success' do
      it 'shows success message'
    end
    context 'when connection fails' do
      it 'exit with non-zero code and show error log'
    end
  end

  describe 'send particular message to websocket server' do
    it 'success'
  end

  describe 'receive message from websocket server' do
    context 'when message equal to scenario' do
      it 'show success message'
    end
    context 'when message not equal to scenarion' do
      it 'shows fail message'
    end
  end

  describe 'after passing all scenarion' do
    it 'shows summary information'
  end
end
