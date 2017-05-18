require 'yaml'

module WSdirector
  class Configuration
    def self.load(script_yml)
      begin
        # parse_script(load_from_yml(script_yml))
        load_from_yml(script_yml)
      rescue => error
        raise "Cofiguration load is failed, please check #{script_yml} - #{error}"
      end
    end

    def self.load_from_yml(script_yml)
      YAML.load_file(script_yml)
    end

    def self.origin(ws_addr)
      full_addr = /(wss?):\/\/(.*)/.match(ws_addr)
      prot, addr = full_addr[1], full_addr[2]
      prot = prot == 'ws' ? 'http' : 'https'
      "#{prot}://#{addr}"
    end
    # def self.parse_script(script)
    # end
  end
end
