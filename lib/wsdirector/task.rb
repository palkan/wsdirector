# frozen_string_literal: true

require "wsdirector/client"

module WSDirector
  # Single client operator
  class Task
    def initialize(config, global_holder:, result:)
      @ignore = config.fetch("ignore")
      @steps = config.fetch("steps")
      @global_holder = global_holder
      @result = result
    end

    def run
      connect!

      steps.each do |step|
        action = build_action(step)

        action.call(client)
      end

      result.succeed
    rescue Error => e
      result.failed(e.message)
    end

    private

    attr_reader :steps, :global_holder, :result, :client

    def connect!
      @client = Client.new(ignore: @ignore)
    end
  end
end
