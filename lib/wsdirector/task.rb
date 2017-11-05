# frozen_string_literal: true

require "wsdirector/client"
require "wsdirector/protocols"

module WSDirector
  # Single client operator
  class Task
    attr_reader :global_holder, :client

    def initialize(config, global_holder:, result:)
      @ignore = config.fetch("ignore")
      @steps = config.fetch("steps")
      @global_holder = global_holder
      @result = result

      protocol_class = Protocols.get(config.fetch("protocol", "base"))
      @protocol = protocol_class.new(self)
    end

    def run
      connect!

      steps.each(&protocol)

      result.succeed
    rescue Error => e
      result.failed(e.message)
    end

    private

    attr_reader :steps, :result, :protocol

    def connect!
      protocol.init_client(ignore: @ignore)
    end
  end
end
