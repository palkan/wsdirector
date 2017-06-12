require 'yaml'

module WSdirector
  class Configuration

    #timeout secs
    TIMEOUT = 5

    def self.parse(script_yml)
      conf = load_from_yml(script_yml)
      conf_parsed = parse_it(conf)
      { 'group' => 'default', 'actions' => conf_parsed }
    rescue => error
      raise "Cofiguration load is failed, please check #{script_yml} - #{error}"
    end

    def self.multiple_parse(script_yml, scale)
      conf = load_from_yml(script_yml)
      result = []
      conf.each.with_index(1) do |v, i|
        v['client']['multiplier'].gsub!(/:scale/, scale.to_s)
        mult = eval(v['client']['multiplier'])
        result << { 'group' => i.to_s, 'multiplier' => mult, 'actions' => parse_it(v['client']['actions']) }
      end
      result
    end

    def self.parse_it(conf)
      result = []
      is_send = false
      conf.each do |i|
        if(i.is_a? String)
          result << i
        elsif(i.keys[0] == 'send')
          result << [:send_receive, i['send']]
        elsif(i.keys[0] == 'receive' && is_send)
          result.last << i['receive']
        else
          result << [:receive, i['receive']]
          is_send = true
        end
      end
      result
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

    def self.test?
      @env == :test
    end

    class << self
      attr_accessor :env
    end
  end
end
