# frozen_string_literal: true

module FixtureHelper
  def fixture_path(path)
    File.join(File.expand_path("../fixtures", __dir__), path)
  end
end
