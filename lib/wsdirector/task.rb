# frozen_string_literal: true

require "wsdirector/client"
require "wsdirector/protocols"

module WSDirector
  # Single client operator
  class Task
    attr_reader :global_holder, :client

    def initialize(config, global_holder:, result:, scale:)
      @ignore = config.fetch("ignore")
      @steps = config.fetch("steps")
      @global_holder = global_holder
      @result = result

      protocol_class = Protocols.get(config.fetch("protocol", "base"))
      @protocol = protocol_class.new(self, scale: scale)
    end

    def run(url)
      connect!(url)

      steps.each(&protocol)

      result.succeed
    rescue Error => e
      result.failed(e.message)
    end

    def sampled?(step)
      return true unless step["sample"]

      id, max = step["id"], step["sample"]

      result.track_sample(id, max)
    end

    private

    attr_reader :steps, :result, :protocol

    def connect!(url)
      protocol.init_client(url: url, ignore: @ignore)
    end
  end
end
