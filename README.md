[![Cult Of Martians](http://cultofmartians.com/assets/badges/badge.svg)](http://cultofmartians.com/tasks/websocket-director.html)
[![Gem Version](https://badge.fury.io/rb/wsdirector-cli.svg)](https://rubygems.org/gems/wsdirector-cli)
[![Build](https://github.com/palkan/wsdirector/workflows/Build/badge.svg)](https://github.com/palkan/wsdirector/actions)

# WebSockets Director

Command line tool for testing websocket servers using scenarios.

Suitable for testing any websocket server implementation, like [Action Cable](https://github.com/rails/rails/tree/master/actioncable), [Websocket Eventmachine Server](https://github.com/imanel/websocket-eventmachine-server), [Litecable](https://github.com/palkan/litecable) and so on.

## Installation

Install CLI:

```sh
gem install wsdirector-cli
```

Or use WebSockets Director as a library:

```ruby
# Gemfile
gem "wsdirector", "~> 1.0"
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

Also you can pass a JSON file with some testing scripts:

```bash
wsdirector -f scenario.json -u ws://websocket.server:9876
```

or pass a JSON scenario directly to the CLI without creating a file:

```bash
wsdirector -i '[{"receive": {"data":"welcome"}},{"send":{"data":"send message"}},{"receive":{"data":"receive message"}}]' -u ws://websocket.server:9876
```

Type `wsdirector --help` to check all commands.

### Protocols

WSDirector uses protocols to handle different actions.
Currently, we support "base" protocol (with `send`, `receive`, `wait_all` actions) and "action_cable" protocol, which extends "base" with `subscribe`, `unsubscribe` and `perform` actions.

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

## Future Ideas

- Report timings (per-client and aggregates)

- Connection parameters (headers, query params, etc)

- Testing frameworks integrations

- Loading protocols dynamically

- What else? [Submit an issue!](https://github.com/palkan/wsdirector/issues/new)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/palkan/wsdirector.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
