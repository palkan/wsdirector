# frozen_string_literal: true

require "open3"

module IntegrationHelpers
  def run_wsdirector(scenario_path, url, chdir: nil, success: true, failure: false, options: "", env: {})
    cli_path = File.expand_path("../../bin/wsdirector", __dir__)

    output, status = Open3.capture2(
      env,
      "bundle exec #{cli_path} -f #{scenario_path} -u #{url} #{options}",
      chdir: chdir || File.expand_path("../fixtures", __dir__)
    )
    expect(status).to be_success, "Test #{scenario_path} #{options} failed with: #{output}" if success && !failure
    expect(status).not_to be_success, "Test #{scenario_path} #{options} succeed with: #{output}" if failure
    output
  end

  def test_script(name = "__test__")
    name = "#{name}.yml" if File.extname(name).empty?

    File.expand_path("../../fixtures/#{name}", __FILE__)
  end
end
