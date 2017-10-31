# frozen_string_literal: true

module WSdirector
  class Printer
    def self.out(message, color)
      return if Configuration.test?
      puts(message).colorize(color)
    end
  end
end
