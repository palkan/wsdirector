# frozen_string_literal: true

module WSDirector
  module Ext
    # Extend Object through refinements
    module Formatting
      refine ::String do
        def truncate(limit)
          return self if size <= limit

          "#{self[0..(limit - 3)]}..."
        end
      end

      refine ::Hash do
        def truncate(limit)
          str = to_json

          str.truncate(limit)
        end
      end

      refine ::Float do
        def duration
          if self > 1
            "#{truncate(2)}s"
          else
            "#{(self * 1000).to_i}ms"
          end
        end
      end
    end
  end
end
