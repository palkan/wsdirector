# frozen_string_literal: true

require "spec_helper"
require "cable_server_helper"

describe "wsdirector vs CableServer with connection params" do
  before(:example) do
    File.write(test_script, content)
  end

  after(:example) do
    File.delete(test_script)
  end

  let(:url) { CableServer.url }

  context "with query string in url" do
    let(:url) { CableServer.url + "?sid=2022" }

    let(:content) do
      <<~YAML
        - client:
            protocol: action_cable
            actions:
              - subscribe:
                  channel: "me"
              - perform:
                  channel: "me"
                  action: "info"
              - receive:
                  channel: "me"
                  data:
                    user: null
                    sid: "2022"
      YAML
    end

    it "shows success message" do
      expect(run_wsdirector(test_script, url)).to include "1 clients, 0 failures"
    end
  end

  context "with headers" do
    let(:content) do
      <<~YAML
        - client:
            protocol: action_cable
            connection_options:
              headers:
                "X-SID": "2022"
            actions:
              - subscribe:
                  channel: "me"
              - perform:
                  channel: "me"
                  action: "info"
              - receive:
                  channel: "me"
                  data:
                    user: null
                    sid: "2022"
      YAML
    end

    it "shows success message" do
      expect(run_wsdirector(test_script, url)).to include "1 clients, 0 failures"
    end
  end

  context "with query in connection options and cookies" do
    let(:content) do
      <<~YAML
        - client:
            protocol: action_cable
            connection_options:
              query:
                "sid": "2022"
              cookies:
                "user": "mike"
            actions:
              - subscribe:
                  channel: "me"
              - perform:
                  channel: "me"
                  action: "info"
              - receive:
                  channel: "me"
                  data:
                    user: "mike"
                    sid: "2022"
      YAML
    end

    it "shows success message" do
      expect(run_wsdirector(test_script, url)).to include "1 clients, 0 failures"
    end
  end
end
