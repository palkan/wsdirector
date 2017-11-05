# frozen_string_literal: true

require "wsdirector/protocols/base"

module WSDirector
  ID2CLASS = {
    "base" => "Base"
  }.freeze

  module Protocols # :nodoc:
    class << self
      def get(id)
        class_name = ID2CLASS.fetch(id)
        const_get(class_name)
      end
    end
  end
end
