# frozen_string_literal: true

require "spec_helper"

describe "wsdirector command" do
  before(:all) { Thread.new { EchoServer.start } }

  after(:all) { EchoServer.stop }

  before(:example) do
    File.open(test_script, "w+") { |file| file.write(content) }
  end

  after(:example) { File.delete(test_script) }

  context "single client" do
    context "when scenario passes" do
      let(:content) do
        <<~YAML
          - send:
              data: "test message"
          - receive:
              data: "test message"
        YAML
      end

      it "show success message and result script" do
        expect(run_wsdirector(test_script)).to include "Success!"
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

      it "show failure message and failes" do
        expect(run_wsdirector(test_script, failure: true)).to include "Failed!"
      end
    end
  end
end
