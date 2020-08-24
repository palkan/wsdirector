# frozen_string_literal: true

CableServer.start

RSpec.configure do |config|
  config.after(:suite) { CableServer.stop }
end
