# frozen_string_literal: true

require "spec_helper"
require "cable_server_helper"

describe "wsdirector vs CableServer with custom protocol" do
  before(:example) do
    File.write(test_script, content)
    File.write(test_script("protocol.rb"), protocol_contents)
  end

  after(:example) do
    File.delete(test_script)
    File.delete(test_script("protocol.rb"))
  end

  let(:url) { CableServer.url }
  let(:options) { "-r #{test_script("protocol.rb")} -vv" }

  let(:protocol_contents) do
    <<~'RUBY'
      module WSDirector::Protocols
        class Hotwired < ActionCable
          def stream_from(step)
            signed_id = step.fetch("signed_id")
            identifier = { channel: "turbo", signed_id: signed_id }.to_json

            send("data" => {command: "subscribe", identifier: identifier})
          end
        end
      end
    RUBY
  end

  context "just connect (no actions, no protocol)" do
    let(:content) do
      <<~YAML
        - client:
            protocol: Hotwired
            actions:
              - stream_from:
                  signed_id: "xyz"
              - receive:
                  data:
                    identifier: '{"channel":"turbo","signed_id":"xyz"}'
                    type: "confirm_subscription"
      YAML
    end

    it "shows success message" do
      expect(run_wsdirector(test_script, url, options: options)).to include "1 clients, 0 failures"
    end
  end
end
