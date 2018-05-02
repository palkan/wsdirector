require "open3"

module IntegrationHelpers
  def run_wsdirector(scenario_path, chdir: nil, success: true, failure: false, options: "", env: {})
    cli_path = File.expand_path("../../../bin/wsdirector", __FILE__)

    output, err, status = Open3.capture3(
      env,
      "bundle exec #{cli_path} #{scenario_path} #{WSDirector.config.ws_url} #{options}",
      chdir: chdir || File.expand_path("../../fixtures", __FILE__)
    )
    expect(status).to be_success, "Test #{scenario_path} #{options} failed with: #{err}" if success && !failure
    expect(status).not_to be_success, "Test #{scenario_path} #{options} succeed with: #{output}" if failure
    output
  end

  def test_script(name = "__test__")
    File.expand_path("../../fixtures/#{name}.yml", __FILE__)
  end
end
