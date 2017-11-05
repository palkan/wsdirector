# frozen_string_literal: true

require "spec_helper"
require "echo_server_helper"

describe "wsdirector vs EchoServer" do
  before(:example) do
    File.open(test_script, "w+") { |file| file.write(content) }
  end

  after(:example) { File.delete(test_script) }

  before { WSDirector.config.ws_url = EchoServer.url }

  context "just connect (no actions)" do
    let(:content) do
      <<~YAML
        - client:
            name: pingo
      YAML
    end

    it "shows success message" do
      expect(run_wsdirector(test_script)).to include "1 clients, 0 failures"
    end
  end

  context "when scenario passes" do
    let(:content) do
      <<~YAML
        - send:
            data: "test message"
        - receive:
            data: "test message"
      YAML
    end

    it "shows success message" do
      expect(run_wsdirector(test_script)).to include "1 clients, 0 failures"
    end
  end

  context "when scenario fails" do
    let(:content) do
      <<~YAML
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

    it "show failure message and errors", :aggregate_failures do
      output = run_wsdirector(test_script, failure: true)
      expect(output).to include "1 clients, 1 failures"
      expect(output).to include("1) Action failed: #receive")
      expect(output).to match(/\-\- expected: .*subscription_confirmation/)
      expect(output).to match(/\+\+ got: .*subscribe/)
    end
  end
end
