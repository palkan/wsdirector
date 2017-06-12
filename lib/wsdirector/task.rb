require 'websocket-client-simple'

module WSdirector
  class Task
    attr_accessor :ws_addr, :test_script, :multiple_clients

    def initialize(ws_addr, test_script = nil, multiple_clients = nil)
      @ws_addr = ws_addr
      @test_script = test_script
      @multiple_clients = multiple_clients
      Thread.abort_on_exception = true
    end

    def self.start(ws_addr, test_script = nil, multiple_clients = nil)
      if multiple_clients && test_script && ws_addr
        new(ws_addr, test_script, multiple_clients).start_multiple_clients
      elsif test_script && ws_addr
        new(ws_addr, test_script).start_one_client
      else
        new(ws_addr).start_cmd_ws
      end
    end

    def run_client(conf, clients_holder, results_holder)
      Thread.new do
        websocket = Websocket.new(ws_addr)
        result = Result.new(conf['group'])
        results_holder << result
        client = Client.new(Marshal.load(Marshal.dump(conf)), websocket, result, conf['group'])
        clients_holder << client

        client.start
      end
    end

    def start_one_client
      conf = Configuration.parse(test_script)
      clients_holder = ClientsHolder.new
      results_holder = ResultsHolder.new

      run_client(conf, clients_holder, results_holder)

      clients_holder.wait_for_finish
      results_holder.print_result
    end

    def start_multiple_clients
      multiple_conf = Configuration.multiple_parse(test_script, multiple_clients)
      all_cnt = multiple_conf.map { |conf| conf['multiplier'] }
      clients_holder = ClientsHolder.new(all_cnt)
      results_holder = ResultsHolder.new

      multiple_conf.each do |conf|
        conf['multiplier'].times { run_client(conf, clients_holder, results_holder) }
      end

      clients_holder.wait_for_finish
      results_holder.print_result
    end

  end
end
