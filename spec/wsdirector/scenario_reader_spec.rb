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
      expect(subject["clients"].size).to eq 2
      expect(subject["clients"].first["steps"].size).to eq 7
      expect(subject["clients"].first["multiplier"]).to eq 1
      expect(subject["clients"].first["steps"].last["type"]).to eq "send"
      expect(subject["clients"].last["steps"].size).to eq 7
      expect(subject["clients"].last["name"]).to eq "listeners"
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
end
