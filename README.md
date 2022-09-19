[![Cult Of Martians](http://cultofmartians.com/assets/badges/badge.svg)](http://cultofmartians.com/tasks/websocket-director.html)
[![Gem Version](https://badge.fury.io/rb/wsdirector-cli.svg)](https://rubygems.org/gems/wsdirector-cli)
[![Build](https://github.com/palkan/wsdirector/workflows/Build/badge.svg)](https://github.com/palkan/wsdirector/actions)

# WebSocket Director

Command line tool for testing WebSocket servers using scenarios.

Suitable for testing any websocket server implementation, like [Action Cable](https://github.com/rails/rails/tree/master/actioncable), [AnyCable](https://anycable.io), [Phoenix Channels](https://hexdocs.pm/phoenix/channels.html), [GraphQL WS](https://github.com/enisdenjo/graphql-ws) and so on.

## Installation

Install CLI:

```sh
gem install wsdirector-cli
```

Or use WebSockets Director as a library (see below for intructions):

```ruby
# Gemfile
gem "wsdirector-core", "~> 1.0"
```

## Usage

Create YAML file with simple testing script:

```yml
# script.yml
- receive: "Welcome" # expect to receive message
- send:
    data: "send message" # send message, all messages in data will be parse to json
- receive:
    data: "receive message" # expect to receive json message
```

and run it with this command:

```bash
wsdirector -f script.yml -u ws://websocket.server:9876/ws

#=> 1 clients, 0 failures
```

You can also use positional arguments:

```sh
wsdirector script.yml ws://websocket.server:9876/ws
```

You can create more complex scenarios with multiple client groups:

```yml
# script.yml
- client: # first clients group
    name: "publisher" # optional group name
    multiplier: ":scale" # :scale take number from -s param, and run :scale number of clients in this group
    actions:
      - receive:
          data: "Welcome"
      - wait_all # makes all clients in all groups wait untill every client get this point (global barrier)
      - send:
          data: "test message"
- client:
    name: "listeners"
    multiplier: ":scale * 2"
    actions:
      - receive:
          data: "Welcome"
      - wait_all
      - receive:
          multiplier: ":scale" # you can use multiplier with any action
          data: "test message"
```

Run with scale factor:

```bash
wsdirector -f script.yml -u ws://websocket.server:9876 -s 10

#=> Group publisher: 10 clients, 0 failures
#=> Group listeners: 20 clients, 0 failures
```

The simpliest scenario is just checking that socket is succesfully connected:

```yml
- client:
    name: connection check
    # no actions
```

Run with loop option:

```yml
  # script.yml
  - client:
      name: "listeners"
      loop:
        multiplier: ":scale" # :scale take number from -s param, and run :scale number of clients in this group
        actions:
          - receive:
              data:
                type: "welcome"
          - send:
              data:
                command: "subscribe"
                identifier: "{\"channel\":\"Channel\"}"
          - receive:
              data:
                identifier: "{\"channel\":\"Channel\"}"
                type: "confirm_subscription"
          - wait_all
          - receive:
              multiplier: ":scale + 1"
```

By default, `receive` action expects the exact `data` match. In some cases, it's useful to only match the specified keys (inclusion). For that, you can use `data>` field instead:

```yml
- client:
  actions:
    - receive:
        data:
          type: "welcome"
    - send:
        data:
          command: "subscribe"
          identifier: "{\"channel\":\"Channel\"}"
    - receive:
        data>:
          type: "confirm_subscription"
```

Also you can pass a JSON file with some testing scripts:

```bash
wsdirector -f scenario.json -u ws://websocket.server:9876
```

or pass a JSON scenario directly to the CLI without creating a file:

```bash
wsdirector -i '[{"receive": {"data":"welcome"}},{"send":{"data":"send message"}},{"receive":{"data":"receive message"}}]' -u ws://websocket.server:9876
```

Type `wsdirector --help` to check all commands.

### Receive order

By default, the `receive` action scans through all available or newly added message to find a matching one.
If you want to check the order of incoming messages, add the `ordered: true` option to the `receive` action.

### Connection configuration

You can specify client's headers, cookies or query string params via the `connection_options` directive:

```yml
- client:
    connection_options:
      headers:
        "X-API-KEY": "secret"
      query:
        token: "123"
      cookies:
        session_id: "2022"
```

**NOTE**: Query string params could also be passed as a part of the URL. Specifying them in the scenario allows you to provide values via the interpolation.

### Using as a library

You can integrate WS Director into your library or application by using its APIs:

```ruby
# Could be a file path or JSON-encoded string as well
scenario = [
  {
    send: {
      data: "ping"
    }
  },
  {
    receive: {
      data: "pong"
    }
  }
]

result = WSDirector.run(scenario, url: "ws://my.ws.server:4949/live")
result.success? #=> true of false
result.groups #=> result data for each client group
```

If you're using YAML-based scenarios, you can also pass local variables to be used with ERB via the `locals` option:

```yml
- client:
    connection_options:
      headers:
        "X-API-TOKEN": <%= token %>
```

```ruby
token = UserToken.generate
WSDirector.run(scenario, url: "ws://my.ws.server:4949/live", locals: {token:})
```

### Protocols

WSDirector uses protocols to handle provide convinient actions for some popular protocols.

#### ActionCable Example

Channel code:

```ruby
class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_test"
  end

  def echo(data)
    transmit data
  end

  def broadcast(data)
    ActionCable.server.broadcast "chat_test", data
  end
end
```

Scenario:

```yml
- client:
    multiplier: ":scale"
    name: "publisher"
    protocol: "action_cable"
    actions:
      - subscribe:
          channel: "ChatChannel"
      - wait_all
      - perform:
          channel: "ChatChannel"
          action: "broadcast"
          data:
            text: "hello"
- client:
    name: "listener"
    protocol: "action_cable"
    actions:
      - subscribe:
          channel: "ChatChannel"
      - wait_all
      - receive:
          channel: "ChatChannel"
          data:
            text: "hello"
```

#### Phoenix Channels

With "phoenix" protocol, you can use communicate with a [Phoenix Channels](https://hexdocs.pm/phoenix/channels.html) server:

```yml
- client:
    protocol: phoenix
    multiplier: ":scale"
    actions:
      - join:
          topic: room:lobby
      - wait_all
      - send:
          topic: room:lobby
          event: new_msg
          data:
            body: "Hey from WS director!"
      - receive:
          topic: room:lobby
          multiplier: ":scale"
          event: new_msg
          data:
            body: "Hey from WS director!"
```

**IMPORTANT**: We support only v2 version of the Channels protocol.

#### Custom protocols

You can define your own protocol and load it dynamically:

```ruby
# It's important to put a custom protocol class under WSDirector::Protocols
module WSDirector::Protocols
  class CustomProtocol < Base
    def send_ping_and_receive_pong
      send("data" => {"type" => "ping"})
      receive("data" => {"type" => "pong"})
    end
  end
end
```

Now you can load it via the `-r` option:

```sh
$ wsdirector -u localhost:3232/ws -i '["send_ping_and_receive_pong"]' -r ./path/to/custom_protocol.rb -vv

hh:mm:ss client=default_1 Connecting
hh:mm:ss client=default_1 Connected (45ms)
hh:mm:ss client=default_1 Sent message: {"type":"ping"}
hh:mm:ss client=default_1 Receive message: {"type":"pong"}
hh:mm:ss client=default_1 Received message: {"type":"pong"} (21ms)
```

## Testing frameworks integration

WSDirector does not provide any specific helpers for RSpec or Minitest. Instead, we provide an example setup, which you could adjust to your needs (and which is too small to be a part of the library).

The example below implies running tests against an Action Cable server with a token-based authentication

```ruby
module WSDirectorTestHelper
  def run_websocket_scenario(path, token:, url: ActionCable.server.config.url, **options)
    url = "#{url}?jid=#{token}"
    scenario = Rails.root.join "spec" / "fixtures" / "wsdirector" / path

    WSDirector.run(scenario, url:, **options)
  end
end

# In RSpec, you can include this modules via the configuration
RSpec.configure do |config|
  # Here we only add this helper to system tests
  config.include WSDirectorTestHelper, type: :system
end
```

## Future Ideas

- Report timings (per-client and aggregates)

- What else? [Submit an issue!](https://github.com/palkan/wsdirector/issues/new)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/palkan/wsdirector.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
