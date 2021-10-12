# frozen_string_literal: true

describe WSDirector::ScenarioReader do
  subject { described_class.parse(scenario) }

  context "with single implicit client" do
    let(:scenario) { fixture_path("scenario_simple.yml") }

    it "contains one client", :aggregate_failures do
      expect(subject["total"]).to eq(1)
      expect(subject["clients"].first["name"]).to eq "default"
      expect(subject["clients"].first["steps"].size).to eq 5
      expect(subject["clients"].first["multiplier"]).to eq 1
      expect(subject["clients"].first["steps"].first["type"]).to eq "receive"
    end
  end

  context "with multiple clients" do
    let(:scenario) { fixture_path("scenario_multiple.yml") }

    it "contains two clients", :aggregate_failures do
      expect(subject["total"]).to eq(3)
      expect(subject["clients"].first["name"]).to eq "1"
      expect(subject["clients"].first["ignore"]).to eq([/ping/])
      expect(subject["clients"].size).to eq 2
      expect(subject["clients"].first["steps"].size).to eq 7
      expect(subject["clients"].first["multiplier"]).to eq 1
      expect(subject["clients"].first["steps"].last["type"]).to eq "send"
      expect(subject["clients"].last["steps"].size).to eq 7
      expect(subject["clients"].last["name"]).to eq "listeners"
      expect(subject["clients"].last["ignore"]).to eq([/ping/])
      expect(subject["clients"].last["multiplier"]).to eq 2
      expect(subject["clients"].last["steps"][3]["type"]).to eq "wait_all"
    end

    context "with scale" do
      before { WSDirector.config.scale = 5 }

      it "parses multipliers", :aggregate_failures do
        expect(subject["total"]).to eq 15
        expect(subject["clients"].size).to eq(2)
        expect(subject["clients"].first["multiplier"]).to eq 5
        expect(subject["clients"].last["multiplier"]).to eq 10
        expect(subject["clients"].last["steps"].size).to eq 15
      end
    end
  end

  context "with ERB" do
    let(:scenario) { fixture_path("scenario_erb.yml") }

    before { ENV["TEST_SCALE"] = "2" }
    after { ENV.delete("TEST_SCALE") }

    it "parses with ERB", :aggregate_failures do
      expect(subject["total"]).to eq 2
      expect(subject["clients"].first["multiplier"]).to eq 2
    end
  end

  context "when single client with loop inside" do
    let(:scenario) { fixture_path("scenario_simple_loop.yml") }

    it "multiplies actions depending on multiplier from a loop" do
      expect(subject["total"]).to eq(1)
      expect(subject["clients"].first["name"]).to eq "default"
      expect(subject["clients"].first["steps"].size).to eq 13
      expect(subject["clients"].first["multiplier"]).to eq 1
      expect(subject["clients"].first["steps"].first["type"]).to eq "receive"
    end
  end

  context "when multiple clients with loop inside" do
    let(:scenario) { fixture_path("scenario_multiple_loop.yml") }

    it "multiplies actions depending on multiplier from a loop" do
      expect(subject["total"]).to eq(2)
      expect(subject["clients"].first["name"]).to eq "1"
      expect(subject["clients"].first["ignore"]).to eq([/ping/])
      expect(subject["clients"].size).to eq 2
      expect(subject["clients"].first["steps"].size).to eq 21
      expect(subject["clients"].first["multiplier"]).to eq 1
      expect(subject["clients"].first["steps"].last["type"]).to eq "send"
      expect(subject["clients"].last["steps"].size).to eq 14
      expect(subject["clients"].last["name"]).to eq "listeners"
      expect(subject["clients"].last["ignore"]).to eq([/ping/])
      expect(subject["clients"].last["multiplier"]).to eq 1
      expect(subject["clients"].last["steps"][3]["type"]).to eq "wait_all"
    end

    context "with scale" do
      before { WSDirector.config.scale = 5 }

      it "parses multipliers with loop", :aggregate_failures do
        expect(subject["total"]).to eq 2
        expect(subject["clients"].size).to eq(2)
        expect(subject["clients"].first["multiplier"]).to eq 1
        expect(subject["clients"].last["multiplier"]).to eq 1
        expect(subject["clients"].last["steps"].size).to eq 150
      end
    end
  end

  context "when format is JSON" do
    context "when it's file" do
      let(:scenario) { fixture_path("json/scenario_simple.json") }

      it "successfully parses it", :aggregate_failures do
        expect(subject["total"]).to eq(1)
        expect(subject["clients"].first["name"]).to eq "default"
        expect(subject["clients"].first["steps"].size).to eq 5
        expect(subject["clients"].first["multiplier"]).to eq 1
        expect(subject["clients"].first["steps"].first["type"]).to eq "receive"
      end
    end

    context "when it's string row from CLI" do
      let(:scenario) { '[{"receive": {"data":"welcome"}},{"send":{"data":"send message"}},{"receive":{"data":"receive message"}}]' }

      it "successfully parses it", :aggregate_failures do
        expect(subject["total"]).to eq(1)
        expect(subject["clients"].first["name"]).to eq "default"
        expect(subject["clients"].first["steps"].size).to eq 3
        expect(subject["clients"].first["multiplier"]).to eq 1
        expect(subject["clients"].first["steps"].first["type"]).to eq "receive"
      end
    end

    context "with multiple clients" do
      let(:scenario) { fixture_path("json/scenario_multiple.json") }

      it "contains two clients", :aggregate_failures do
        expect(subject["total"]).to eq(3)
        expect(subject["clients"].first["name"]).to eq "1"
        expect(subject["clients"].first["ignore"]).to eq(["ping"])
        expect(subject["clients"].size).to eq 2
        expect(subject["clients"].first["steps"].size).to eq 7
        expect(subject["clients"].first["multiplier"]).to eq 1
        expect(subject["clients"].first["steps"].last["type"]).to eq "send"
        expect(subject["clients"].last["steps"].size).to eq 7
        expect(subject["clients"].last["name"]).to eq "listeners"
        expect(subject["clients"].last["ignore"]).to eq(["ping"])
        expect(subject["clients"].last["multiplier"]).to eq 2
        expect(subject["clients"].last["steps"][3]["type"]).to eq "wait_all"
      end
    end

    context "with loop inside" do
      let(:scenario) { fixture_path("json/scenario_simple_loop.json") }

      it "contains two clients", :aggregate_failures do
        expect(subject["total"]).to eq(1)
        expect(subject["clients"].first["name"]).to eq "default"
        expect(subject["clients"].first["steps"].size).to eq 13
        expect(subject["clients"].first["multiplier"]).to eq 1
        expect(subject["clients"].first["steps"].first["type"]).to eq "receive"
      end
    end
  end
end
