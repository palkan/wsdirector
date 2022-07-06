# frozen_string_literal: true

require "spec_helper"
require "cable_server_helper"

describe "wsdirector vs CableServer" do
  before(:example) do
    File.write(test_script, content)
  end

  after(:example) { File.delete(test_script) }

  let(:url) { CableServer.url }

  context "just connect (no actions, no protocol)" do
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

  context "multiple connect with protocol" do
    let(:content) do
      <<~YAML
        - client:
            multiplier: 3
            protocol: "action_cable"
      YAML
    end

    it "shows success message" do
      expect(run_wsdirector(test_script, url)).to include "3 clients, 0 failures"
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
      output = run_wsdirector(test_script, url, options: "-s 3")
      expect(output).to include "Group publishers: 3 clients, 0 failures"
      expect(output).to include "Group listeners: 6 clients, 0 failures"
    end
  end

  context "multiple clients with receive_all" do
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
                  action: "speak_with_ack"
                  multiplier: 3
                  data:
                    message: "Hello!"
              - receive_all:
                  messages:
                    - data:
                        text: "Hello!"
                      multiplier: ":scale + :scale"
                      channel: "chat"
                      params:
                        id: 2
                    - data:
                        text: "message sent"
                      channel: "chat"
                      params:
                        id: 2
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
      output = run_wsdirector(test_script, url, options: "-s 1")
      expect(output).to include "Group publishers: 1 clients, 0 failures"
      expect(output).to include "Group listeners: 2 clients, 0 failures"
    end
  end

  context "when failed with wrong subscription and missing receive" do
    let(:content) do
      <<~YAML
        - client:
            protocol: "action_cable"
            actions:
              - subscribe:
                  channel: "chat"
              - wait_all

        - client:
            protocol: "action_cable"
            actions:
              - subscribe:
                  channel: "chat"
                  params:
                    id: 2
              - wait_all
              - receive:
                  channel: "chat"
                  params:
                    id: 2
                  data:
                    text: "Hello!"
      YAML
    end

    it "shows failure message", :aggregate_failures do
      output = run_wsdirector(test_script, url, failure: true)
      expect(output).to include "Group 1: 1 clients, 1 failures"
      expect(output).to include "Group 2: 1 clients, 1 failures"
      expect(output).to include "Subscription rejected to"
      expect(output).to match(/Timeout .* exceeded for #wait_all/)
    end
  end

  context "sampling" do
    let(:content) do
      <<~YAML
        - client:
            multiplier: ":scale"
            protocol: "action_cable"
            actions:
              - subscribe:
                  channel: "chat"
                  params:
                    id: 2
              - wait_all
              - perform:
                  sample: ":scale / 2"
                  channel: "chat"
                  params:
                    id: 2
                  action: "speak"
                  data:
                    message: "Hello!"
              - perform:
                  sample: 1
                  channel: "chat"
                  params:
                    id: 2
                  action: "speak"
                  data:
                    message: "Goodbye!"
              - perform:
                  sample: "1 + 1"
                  channel: "chat"
                  params:
                    id: 2
                  action: "speak"
                  data:
                    message: "..."
              - receive_all:
                  messages:
                    - channel: "chat"
                      multiplier: ":scale / 2"
                      params:
                        id: 2
                      data:
                        text: "Hello!"
                    - channel: "chat"
                      params:
                        id: 2
                      data:
                        text: "Goodbye!"
                    - channel: "chat"
                      multiplier: 2
                      params:
                        id: 2
                      data:
                        text: "..."
      YAML
    end

    it "shows success message", :aggregate_failures do
      output = run_wsdirector(test_script, url, options: "-s 4")
      expect(output).to include "4 clients, 0 failures"
    end
  end
end
