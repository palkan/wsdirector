# frozen_string_literal: true

require "spec_helper"
require "cable_server_helper"

describe "wsdirector vs CableServer" do
  before(:example) do
    File.open(test_script, "w+") { |file| file.write(content) }
  end

  after(:example) { File.delete(test_script) }

  before { WSDirector.config.ws_url = CableServer.url }

  context "just connect (no actions, no protocol)" do
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

  context "multiple connect with protocol" do
    let(:content) do
      <<~YAML
        - client:
            multiplier: 3
            protocol: "action_cable"
      YAML
    end

    it "shows success message" do
      expect(run_wsdirector(test_script)).to include "3 clients, 0 failures"
    end
  end

  context "multiple clients with wait_all" do
    let(:content) do
      <<~YAML
        - client:
            multiplier: ":scale"
            protocol: "action_cable"
            name: "publishers"
            actions:
              - subscribe:
                  channel: "chat"
                  params:
                    id: 2
              - wait_all
              - perform:
                  channel: "chat"
                  params:
                    id: 2
                  action: "speak"
                  multiplier: 3
                  data:
                    message: "Hello!"

        - client:
            multiplier: ":scale * 2"
            name: "listeners"
            protocol: "action_cable"
            actions:
              - subscribe:
                  channel: "chat"
                  params:
                    id: 2
              - wait_all
              - receive:
                  multiplier: ":scale + :scale"
                  channel: "chat"
                  params:
                    id: 2
                  data:
                    text: "Hello!"
      YAML
    end

    it "shows success message", :aggregate_failures do
      output = run_wsdirector(test_script, options: "-s 3")
      expect(output).to include "Group publishers: 3 clients, 0 failures"
      expect(output).to include "Group listeners: 6 clients, 0 failures"
    end
  end
end
