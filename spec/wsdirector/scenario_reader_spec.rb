# frozen_string_literal: true

describe WSDirector::ScenarioReader do
  subject { described_class.parse(file_path) }

  context "with single implicit client" do
    let(:file_path) { fixture_path("scenario_simple.yml") }

    it "contains one client", :aggregate_failures do
      expect(subject["total"]).to eq(1)
      expect(subject["clients"].first["name"]).to eq "default"
      expect(subject["clients"].first["steps"].size).to eq 5
      expect(subject["clients"].first["multiplier"]).to eq 1
      expect(subject["clients"].first["steps"].first["type"]).to eq "receive"
    end
  end

  context "with multiple clients" do
    let(:file_path) { fixture_path("scenario_multiple.yml") }

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

  context "with loop option" do
    context "and scenario is simple" do
      let(:file_path) { fixture_path("scenario_loop_simple.yml") }

      it "contains one looped client", :aggregate_failures do
        expect(subject["total"]).to eq(13)
        expect(subject["clients"].first["name"]).to eq "default"
        expect(subject["clients"].first["steps"].size).to eq 1
        expect(subject["clients"].first["multiplier"]).to eq 1
        expect(subject["clients"].first["steps"].first["type"]).to eq "receive"

        expect(subject["clients"].last["name"]).to eq "default"
        expect(subject["clients"].last["steps"].size).to eq 12
        expect(subject["clients"].last["multiplier"]).to eq 3
        expect(subject["clients"].last["steps"].first["type"]).to eq "send"
      end
    end

    context "and scenario with multiple clients" do
      let(:file_path) { fixture_path("scenario_loop_multiple.yml") }

      it "contains multiple looped clients", :aggregate_failures do
        expect(subject["total"]).to eq(31)
        expect(subject["clients"].size).to eq 2

        expect(subject["clients"].first["name"]).to eq "1"
        expect(subject["clients"].first["ignore"]).to eq([/ping/])
        expect(subject["clients"].first["steps"].size).to eq 21
        expect(subject["clients"].first["multiplier"]).to eq 3
        expect(subject["clients"].first["steps"].last["type"]).to eq "send"

        expect(subject["clients"].last["name"]).to eq "listeners"
        expect(subject["clients"].last["ignore"]).to eq([/ping/])
        expect(subject["clients"].last["steps"].size).to eq 10
        expect(subject["clients"].last["multiplier"]).to eq 2
        expect(subject["clients"].last["steps"].last["type"]).to eq "receive"
      end

      context "with scale" do
        before { WSDirector.config.scale = 5 }

        it "parses multipliers", :aggregate_failures do
          expect(subject["total"]).to eq 71
          expect(subject["clients"].size).to eq(2)

          expect(subject["clients"].first["multiplier"]).to eq 3
          expect(subject["clients"].first["steps"].size).to eq 21

          expect(subject["clients"].last["multiplier"]).to eq 10
          expect(subject["clients"].last["steps"].size).to eq 50
        end
      end
    end
  end

  context "with ERB" do
    let(:file_path) { fixture_path("scenario_erb.yml") }

    before { ENV["TEST_SCALE"] = "2" }
    after { ENV.delete("TEST_SCALE") }

    it "parses with ERB", :aggregate_failures do
      expect(subject["total"]).to eq 2
      expect(subject["clients"].first["multiplier"]).to eq 2
    end
  end
end
