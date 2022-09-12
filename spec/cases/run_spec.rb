# frozen_string_literal: true

require "spec_helper"
require "cable_server_helper"

describe "WSDirector.run" do
  let(:url) { CableServer.url }

  let(:options) { {} }
  let(:scenario) { [] }

  subject { WSDirector.run(scenario, url: url, **options) }

  it "works" do
    expect(subject).to be_success
  end

  context "with file" do
    before(:example) do
      File.write(test_script, content)
    end

    after(:example) do
      File.delete(test_script)
    end

    let(:content) do
      <<~YAML
        - client:
            protocol: action_cable
            connection_options:
              cookies:
                user: <%= user %>
              query:
                sid: <%= sid %>
            actions:
              - subscribe:
                  channel: "me"
              - perform:
                  channel: "me"
                  action: "info"
              - receive:
                  channel: "me"
                  data:
                    user: "api"
                    sid: "2022"
      YAML
    end

    let(:scenario) { test_script }
    let(:options) { {locals: {user: "api", sid: "2022"}} }

    it "support passing locals" do
      expect(subject).to be_success
    end
  end
end
