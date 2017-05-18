require "spec_helper"
require_relative 'echo_server'

describe WSdirector do

  before(:context) do
    Thread.new { WSdirector::EchoServer.start }
  end

  let(:test_script) { 'test_script.yml' }

  it "has a version number" do
    expect(WSdirector::VERSION).not_to be nil
  end

  describe 'connect to websocket server' do
    context 'when connection success' do
      it 'shows success message' do
        expect { WSdirector::Task.start(nil, 'ws://localhost:9876');sleep 1 }.to output(/^Connection established - ws:\/\/localhost:9876.*/).to_stdout
      end
      it 'show welcome server message' do
        expect { WSdirector::Task.start(nil, 'ws://localhost:9876');sleep 1 }.to output(/.* Welcome\n$/).to_stdout
      end
    end

    context 'when connection fails' do
      it 'exit with non-zero code and show error log' do
        expect { WSdirector::Task.start(nil, 'ws://localhost:9999');sleep 1 }.to raise_error(/^Connection problems - .*/)
      end
    end
  end

  context 'simple script with echo server' do
    context 'when websocket pass test' do
      let(:content) do
        <<-YAML.strip_heredoc
          - receive:
              data: "Welcome"
          - send:
              data: "test message"
          - receive:
              data: "test message"
        YAML
      end

      before(:example) do
        File.open(test_script, "w+") { |file| file.write(content) }
      end

      after(:example) { File.delete(test_script) }

      it 'show success message and result script' do
        WSdirector::Task.start(test_script, 'ws://127.0.0.1:9876')
      end
    end

    context "when websocket test did't pass" do
      let(:content) do
        <<-YAML.strip_heredoc
          - receive:
              data:
                type: "Welcome"
          - send:
              data:
                command: "subscribe"
                identifier: '{\"channel\":\"TestChannel\"}'
          - receive:
              data:
                type: "subscription_confirmation"
                identifier: '{\"channel\":\"TestChannel\"}'

        YAML
      end

      before(:example) do
        File.open(test_script, "w+") { |file| file.write(content) }
      end

      after(:example) { File.delete(test_script) }

      it "show fails message and fails"
    end
  end
end
