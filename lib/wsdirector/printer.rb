# frozen_string_literal: true

module WSDirector
  # Print messages (optionally colorized) to STDOUT
  class Printer
    def self.out(message, color = nil)
      message = message.colorize(color) if WSDirector.config.colorize? && color
      $stdout.puts(message)
    end
  end
end
