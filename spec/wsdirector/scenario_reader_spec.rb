describe WSDirector::ScenarioReader do
  subject { described_class.parse(file_path) }

  context "with single implicit client" do
    let(:file_path) { fixture_path("scenario_simple.yml") }

    it "contains one client", :aggregate_failures do
      expect(subject.size).to eq(1)
      expect(subject.first["steps"].size).to eq 5
      expect(subject.first["multiplier"]).to eq 1
      expect(subject.first["steps"].first["type"]).to eq "receive"
    end
  end

  context "with multiple clients" do
    let(:file_path) { fixture_path("scenario_multiple.yml") }

    it "contains two clients", :aggregate_failures do
      expect(subject.size).to eq(2)
      expect(subject.first["steps"].size).to eq 7
      expect(subject.first["multiplier"]).to eq 1
      expect(subject.first["steps"].last["type"]).to eq "send"
      expect(subject.last["steps"].size).to eq 7
      expect(subject.last["multiplier"]).to eq 2
      expect(subject.last["steps"][3]["type"]).to eq "wait_all"
    end

    context "with scale" do
      before { WSDirector.config.scale = 5 }

      it "parses multipliers", :aggregate_failures do
        expect(subject.size).to eq(2)
        expect(subject.first["multiplier"]).to eq 5
        expect(subject.last["multiplier"]).to eq 10
        expect(subject.last["steps"].size).to eq 15
      end
    end
  end
end
