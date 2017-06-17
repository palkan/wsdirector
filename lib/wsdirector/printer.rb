require 'colorize'

module WSdirector
  class Printer
    def self.out(message, color)
      return if Configuration.test?
      puts message.colorize(color)
    end
  end
end
