# frozen_string_literal: true

require "wsdirector/client"
require "wsdirector/protocols"

module WSDirector
  # Single client operator
  class Task
    attr_reader :global_holder, :client

    def initialize(config, id:, global_holder:, result:, scale:, logger:, colorize: false)
      @id = id
      @logger = logger
      @ignore = config.fetch("ignore")
      @steps = config.fetch("steps")
      @connection_options = config.fetch("connection_options").transform_keys(&:to_sym)
      @global_holder = global_holder
      @result = result

      protocol_class = Protocols.get(config.fetch("protocol", "base"))
      @protocol = protocol_class.new(self, scale: scale, logger: logger, id: id, color: color_for_id(id, colorize))
    end

    def run(url)
      connect!(url, **@connection_options)

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

    attr_reader :steps, :result, :protocol, :id, :logger

    def connect!(url, **options)
      protocol.init_client(url: url, id: id, ignore: @ignore, **options)
    end

    def color_for_id(id, colorize)
      return unless colorize

      String.colors[id.object_id % String.colors.size]
    end
  end
end
