module FixtureHelper
  def fixture_path(path)
    File.join(File.expand_path("../../fixtures", __FILE__), path)
  end
end
