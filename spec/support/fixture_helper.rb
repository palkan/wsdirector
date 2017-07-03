module FixtureHelper
  def self.simple_scenario_path
    self.path('test_scenario.yml')
  end

  def self.multi_client_scenario_path
    self.path('test_multi_scenario.yml')
  end

  def self.path(file_name)
    File.join(File.dirname(__dir__), '..', 'spec', 'fixtures', file_name)
  end
end
