require 'spec_helper'

describe WsDirector::ScenarioReader do
  context 'simple scenario' do
    let(:file_path) { FixtureHelper.simple_scenario_path }

    it 'contains one client' do
      scenario_hash = WsDirector::ScenarioReader.new(file_path).to_hash
      expect(scenario_hash.length).to be(1)
    end
  end

  context 'multiclient scenario' do
    let(:file_path) { FixtureHelper.multi_client_scenario_path }

    it 'contains two clients' do
      scenario_hash = WsDirector::ScenarioReader.new(file_path).to_hash
      expect(scenario_hash.length).to be(2)
    end
  end
end
