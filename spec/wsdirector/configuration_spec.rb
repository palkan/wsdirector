require "spec_helper"

describe WSdirector::Configuration do
  subject { WSdirector::Configuration }

  let(:test_script) { 'test_script.yml' }

  describe '.load' do
    context 'when check test_script file and it didnt exist' do
      it 'raise exception' do
        expect { subject.load(test_script) }.to raise_error(/Cofiguration load is failed, please check /)
      end
    end

    context 'when test_script file exist' do

      let(:content) do
        <<-YAML.strip_heredoc
          - receive:
              data:
                type: "welcome"
          - send:
              data:
                command: "subscribe"
                identifier: '{"channel":"TestChannel"}'
          - receive:
              data:
                type: "subscription_confirmation"
                identifier: '{"channel":"TestChannel"}'

        YAML
      end

      let(:broken_content) { "broken_content: '''" }

      context 'when yml valid' do
        before(:example) do
          File.open(test_script, "w+") { |file| file.write(content) }
        end
        after(:example) { File.delete(test_script) }

        it 'call parse_script method' do
          expect(subject).to receive(:parse_script).with(instance_of(Array))
          subject.load(test_script)
        end
      end

      context 'when yml invalid' do
        before(:example) do
          File.open(test_script, "w+") { |file| file.write(broken_content) }
        end
        after(:example) { File.delete(test_script) }

        it 'raise exception' do
          # expect(subject.load(test_script)).to eq(false)
          expect { subject.load(test_script) }.to raise_error(/Cofiguration load is failed, please check /)
        end
      end

      context 'when parsing success' do
          it 'return parsed config' do
            fake_parsed_config = [{ config: 'config'}]
            allow(File).to receive(:exist?).and_return true
            allow(subject).to receive(:load_from_yml)
            allow(subject).to receive(:parse_script).and_return(fake_parsed_config)
            expect(subject.load(test_script)).to eq(fake_parsed_config)
          end
      end

    end
  end
end
