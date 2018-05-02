# frozen_string_literal: true

module WSDirector
  module Utils # :nodoc:
    MULTIPLIER_FORMAT = /^[-+*\\\d ]+$/

    def parse_multiplier(str)
      prepared = str.to_s.gsub(":scale", WSDirector.config.scale.to_s)
      raise WSDirector::Error, "Unknown multiplier format: #{str}" unless
        prepared =~ MULTIPLIER_FORMAT

      eval(prepared) # rubocop:disable Security/Eval
    end
  end
end
