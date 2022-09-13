# frozen_string_literal: true

require "spec_helper"
require "echo_server_helper"

describe "wsdirector vs EchoServer" do
  before(:example) do
    File.write(test_script, content)
  end

  after(:example) { File.delete(test_script) }

  let(:url) { EchoServer.url }

  context "just connect (no actions)" do
    let(:content) do
      <<~YAML
        - client:
            name: pingo
      YAML
    end

    it "shows success message" do
      expect(run_wsdirector(test_script, url)).to include "1 clients, 0 failures"
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
      expect(run_wsdirector(test_script, url)).to include "1 clients, 0 failures"
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
      output = run_wsdirector(test_script, url, failure: true)
      expect(output).to include "1 clients, 1 failures"
      expect(output).to include("1) Action failed: #receive")
      expect(output).to match(/-- expected: .*subscription_confirmation/)
      expect(output).to match(/\+\+ got: .*subscribe/)
    end
  end

  context "receive with partial match" do
    let(:content) do
      <<~YAML
        - send:
            data:
              command: "subscribe"
              identifier: '{\"channel\":\"TestChannel\"}'
        - receive:
            data>:
              command: "subscribe"

      YAML
    end

    it "show success message", :aggregate_failures do
      output = run_wsdirector(test_script, url)
      expect(output).to include "1 clients, 0 failures"
    end
  end

  context "receive order non-strict" do
    let(:content) do
      <<~YAML
        - send:
            data: "receive a to b"
        - receive:
            data: b
        - receive:
            data: a

      YAML
    end

    it "show success message", :aggregate_failures do
      output = run_wsdirector(test_script, url)
      expect(output).to include "1 clients, 0 failures"
    end
  end

  context "receive order strict" do
    let(:content) do
      <<~YAML
        - send:
            data: "receive a to b"
        - receive:
            data: b
            ordered: true
        - receive:
            data: a

      YAML
    end

    it "show failure message", :aggregate_failures do
      output = run_wsdirector(test_script, url, failure: true)
      expect(output).to include "1 clients, 1 failures"
      expect(output).to include("1) Action failed: #receive")
      expect(output).to match(/-- expected: "b"/)
      expect(output).to match(/\+\+ got: a/)
    end
  end
end
