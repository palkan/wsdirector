# frozen_string_literal: true

require "wsdirector/protocols/base"
require "wsdirector/protocols/action_cable"
require "wsdirector/protocols/phoenix"

module WSDirector
  ID2CLASS = {
    "base" => "Base",
    "action_cable" => "ActionCable",
    "phoenix" => "Phoenix"
  }.freeze

  module Protocols # :nodoc:
    # Raised when received not expected message
    class UnmatchedExpectationError < WSDirector::Error; end

    # Raised when received message is unexpected
    class UnexpectedMessageError < WSDirector::Error; end

    # Raised when nothing has been received
    class NoMessageError < WSDirector::Error; end

    class << self
      def get(id)
        class_name = if ID2CLASS.key?(id)
          ID2CLASS.fetch(id)
        else
          id
        end

        const_get(class_name)
      rescue NameError
        raise Error, "Unknown protocol: #{id}"
      end
    end
  end
end
