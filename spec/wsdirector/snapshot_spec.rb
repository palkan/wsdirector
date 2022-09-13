# frozen_string_literal: true

describe WSDirector::Snapshot do
  subject(:snapshot) { described_class.new }

  before do
    snapshot << {"message" => "a"}
    sleep 1
    snapshot << {"message" => "b"}
  end

  it "collects frames with intervals" do
    actual = JSON.parse(snapshot.to_json)
    expect(actual.size).to eq(3)
    expect(actual[0]).to eq("send" => {
      "data" => {
        "message" => "a"
      }
    })
    expect(actual[1].fetch("sleep").fetch("time")).to be >= 1.0
    expect(actual[2]).to eq("send" => {
      "data" => {
        "message" => "b"
      }
    })
  end

  it "#to_yml" do
    yaml = snapshot.to_yml

    scenario = WSDirector::ScenarioReader.parse(yaml)

    expect(scenario["total"]).to eq(1)
    steps = scenario["clients"].first["steps"]

    expect(steps.size).to eq(3)
    expect(steps.map { |step| step["type"] })
      .to match_array(%w[send sleep send])
  end
end
