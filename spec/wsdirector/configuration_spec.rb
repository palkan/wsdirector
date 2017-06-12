require "spec_helper"

describe WSdirector::Configuration do
  subject { WSdirector::Configuration }

  let(:test_script) { 'test.yml' }

  let(:content) do
    <<-YAML.strip_heredoc
      - receive:
          data:
            type: "welcome"
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

  let(:multiple_content) do
    <<-YAML.strip_heredoc
      - client:
          multiplier: ":scale"
          actions:
            - receive:
                data:
                  type: "welcome"
            - send:
                data:
                  command: "subscribe"
                  identifier: '{\"channel\":\"TestChannel\"}'
            - receive:
                data:
                  type: "subscription_confirmation"
                  identifier: '{\"channel\":\"TestChannel\"}'
      - client:
          multiplier: ":scale * 10"
          actions:
            - receive:
                data:
                  type: "welcome"
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

  let(:broken_content) { "broken_content: '''" }

  let(:parsed_script) do
    [
      [:receive, { 'data' => { 'type' => 'welcome' } }],
      [:send_receive,
        { 'data' => { 'command' => 'subscribe', 'identifier' => "{\"channel\":\"TestChannel\"}" } },
        { 'data' => { 'type' => 'subscription_confirmation', 'identifier' => "{\"channel\":\"TestChannel\"}" } }
      ]
    ]
  end

  describe '.parse' do
    context 'when check test_script file and it didnt exist' do
      it 'raise exception' do
        expect { subject.parse(test_script) }.to raise_error(/Cofiguration load is failed, please check /)
      end
    end

    context 'when test_script file exist' do
      context 'when yml invalid' do
        before(:example) do
          File.open(test_script, "w+") { |file| file.write(broken_content) }
        end
        after(:example) { File.delete(test_script) }

        it 'raise exception' do
          expect { subject.parse(test_script) }.to raise_error(/Cofiguration load is failed, please check /)
        end
      end

      context 'when parsing success' do
        before(:example) do
          File.open(test_script, "w+") { |file| file.write(content) }
        end
        after(:example) { File.delete(test_script) }

        it 'return parsed config' do
          allow(subject).to receive(:parse_it).and_return(parsed_script)
          returned_hash = { 'group' => 'default', 'actions' => parsed_script }
          expect(subject.parse(test_script)).to eq(returned_hash)
        end
      end
    end
  end

  describe '.multiple_parse' do
    let(:parsed_miltiple_script) do
      [
        { 'group' => '1', 'multiplier' => 10, 'actions' => parsed_script },
        { 'group' => '2', 'multiplier' => 100, 'actions' => parsed_script }
      ]
    end

    context 'when parsing success' do
      before(:example) do
        File.open(test_script, "w+") { |file| file.write(multiple_content) }
      end
      after(:example) { File.delete(test_script) }

      it 'return parsed multiple config' do
        expect(subject.multiple_parse(test_script, 10)).to eq(parsed_miltiple_script)
      end
    end
  end

  describe '.parse_it' do
    it 'return expected result with receive start' do
      conf = [
        {"receive"=>{"data"=>{"type"=>"welcome"}}},
        {
          "send"=>{"data"=>{"command"=>"subscribe",
          "identifier"=>"{\"channel\":\"TestChannel\"}"}}
        },
        {
          "receive"=>{"data"=>{"type"=>"subscription_confirmation",
          "identifier"=>"{\"channel\":\"TestChannel\"}"}}
        }
      ]
      expect(WSdirector::Configuration.parse_it(conf)).to eq(parsed_script)
    end

    it 'return expected result with send_receive start' do
      conf = [
        {
          "send"=>{"data"=>{"command"=>"subscribe",
          "identifier"=>"{\"channel\":\"TestChannel\"}"}}
        },
        {
          "receive"=>{"data"=>{"type"=>"subscription_confirmation",
          "identifier"=>"{\"channel\":\"TestChannel\"}"}}
        }
      ]
      result = [
          [:send_receive,
            { 'data' => { 'command' => 'subscribe', 'identifier' => "{\"channel\":\"TestChannel\"}" } },
            { 'data' => { 'type' => 'subscription_confirmation', 'identifier' => "{\"channel\":\"TestChannel\"}" } }
          ]
        ]
      expect(WSdirector::Configuration.parse_it(conf)).to eq(result)
    end
  end

  describe '.origin' do
    it 'return origin address' do
      ws_addr = 'ws://localhost:9876'
      expect(subject.origin(ws_addr)).to eq('http://localhost:9876')
    end
  end

  describe '.test?' do
    it 'true if test env' do
      # subject.env = :test
      allow(subject).to receive(:env).and_return(:test)
      expect(subject.test?).to eq(true)
    end
    it 'false if not test env' do
      # subject.env = nil
      allow(subject).to receive(:env).and_return(nil)
      expect(subject.test?).to eq(false)
    end
  end
end
