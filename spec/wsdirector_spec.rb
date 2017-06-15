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

  context 'when params fails' do
    it 'exit with error when there is no file' do
      expect { WSdirector::Task.start('ws://127.0.0.1:9876', test_script) }.to raise_error(/No such file or directory/)
    end

    it 'exit with error when script is not specified' do
      expect { WSdirector::Task.start('ws://127.0.0.1:9876') }.to raise_error('Error! Missing script file path or websocket server address.')
    end

    it 'exit with error when websocket addr is not specified' do
      expect { WSdirector::Task.start(test_script) }.to raise_error('Error! Missing script file path or websocket server address.')
    end

    it 'exit with error when yaml file invalid' do
      content = <<-YAML.strip_heredoc
                  receive "Welcome"
                  data "test message"
                YAML

      File.open(test_script, "w+") { |file| file.write(content) }
      expect { WSdirector::Task.start('ws://127.0.0.1:9876', test_script) }.to raise_error(/Cofiguration load is failed, please check/)
      File.delete(test_script)
    end
  end

  context 'simple script with echo server' do
    context 'when websocket pass test' do
      let(:content) do
        <<-YAML.strip_heredoc
          - receive: "Welcome"
          - send:
              data: "test message"
          - receive:
              data: "test message"
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

      it 'succefful perform all tasks' do
        expect { WSdirector::Task.start('ws://127.0.0.1:9876', test_script) }.to_not raise_error
      end
    end

    context "when websocket test did't pass" do
      let(:content) do
        <<-YAML.strip_heredoc
          - receive:
              data:
                type: "Welcome"
          - send:
              data: "payload"
          - receive:
              data: "fake"
        YAML
      end

      before(:example) do
        File.open(test_script, "w+") { |file| file.write(content) }
      end

      after(:example) { File.delete(test_script) }

      it "fails to perform tasks" do
        expect { WSdirector::Task.start('ws://127.0.0.1:9876', test_script) }.to raise_error("Websocket test fails")
      end
    end
  end

  context 'simple script with muptiple clients' do
    context 'when websocket pass test' do
      let(:content) do
        <<-YAML.strip_heredoc
          - client:
              multiplier: "5 * :scale"
              actions:
                - receive: "Welcome"
                - wait_all
                - send:
                    data: "test message"
                - receive:
                    data: "test message"
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

      it 'succefful perform all tasks' do
        expect { WSdirector::Task.start('ws://127.0.0.1:9876', test_script, 1) }.to_not raise_error
      end
    end

    context 'when websocket fails test' do
      let(:content) do
        <<-YAML.strip_heredoc
          - client:
              multiplier: "5 * :scale"
              actions:
                - receive: "Welcome"
                - send:
                    data: "test message"
                - receive:
                    data: "fail"
                - send:
                    data: "test message"
                - receive:
                    data: "fail"
        YAML
      end

      before(:example) do
        File.open(test_script, "w+") { |file| file.write(content) }
      end

      after(:example) { File.delete(test_script) }

      it 'fails perform all tasks' do
        expect { WSdirector::Task.start('ws://127.0.0.1:9876', test_script, 1) }.to raise_error("Websocket test fails")
      end
    end
  end

  context 'simple script with muptiple clients and two groups' do
    context 'when websocket pass test' do
      let(:content) do
        <<-YAML.strip_heredoc
          - client:
              multiplier: ":scale"
              actions:
                - receive: "Welcome"
                - wait_all
                - send:
                    data: "test message"
          - client:
              multiplier: "10 * :scale"
              actions:
                - receive: "Welcome"
                - wait_all
                - receive:
                    data: "test message"
        YAML
      end

      before(:example) do
        File.open(test_script, "w+") { |file| file.write(content) }
      end

      after(:example) { File.delete(test_script) }

      it 'succefful perform all tasks' do
        expect { WSdirector::Task.start('ws://127.0.0.1:9876', test_script, 1) }.to_not raise_error
      end
    end

    context 'when websocket fails test' do
      let(:content) do
        <<-YAML.strip_heredoc
          - client:
              multiplier: ":scale"
              actions:
                - receive: "Welcome"
                - wait_all
                - send:
                    data: "test message"
          - client:
              multiplier: "10 * :scale"
              actions:
                - receive: "Welcome"
                - wait_all
                - receive:
                    data: "fails message"
        YAML
      end

      before(:example) do
        File.open(test_script, "w+") { |file| file.write(content) }
      end

      after(:example) { File.delete(test_script) }

      it 'fails perform all tasks' do
        expect { WSdirector::Task.start('ws://127.0.0.1:9876', test_script, 1) }.to raise_error("Websocket test fails")
      end
    end
  end

end
