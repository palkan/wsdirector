# frozen_string_literal: true

module WSDirector
  module Utils # :nodoc:
    MULTIPLIER_FORMAT = /^[-+*\/\\\d ]+$/

    attr_reader :scale

    def parse_multiplier(str)
      prepared = str.to_s.gsub(":scale", scale.to_s)
      raise WSDirector::Error, "Unknown multiplier format: #{str}" unless
        MULTIPLIER_FORMAT.match?(prepared)

      eval(prepared) # rubocop:disable Security/Eval
    end
  end
end
