[![Gem Version](https://badge.fury.io/rb/wsdirector.svg)](https://rubygems.org/gems/wsdirector) [![CircleCI](https://circleci.com/gh/palkan/wsdirector.svg?style=svg)](https://circleci.com/gh/palkan/wsdirector) 

# WebSocket Director

Command line tool for testing websocket servers using scenarios.

Suitable for testing any websocket server implementation, like [Action Cable](https://github.com/rails/rails/tree/master/actioncable), [Websocket Eventmachine Server](https://github.com/imanel/websocket-eventmachine-server), [Litecable](https://github.com/palkan/litecable) and so on.

Also can be used for stress testing.

<a href="https://evilmartians.com/">
<img src="https://evilmartians.com/badges/sponsored-by-evil-martians.svg" alt="Sponsored by Evil Martians" width="236" height="54"></a>

## Installation

```bash
  $ gem install wsdirector
```

## Usage

Create yaml file with simle testing script, like that

```yml
  # script.yml
  - receive: "Welcome" # expect to receive message
  - send:
      data: "send message" # send message, all messages in data will be parse to json
  - receive:
      data: "receive message" # expect to receive json message
```
and run it with this command
```bash
wsdirector ws://websocket.server:9876 script.yml # in case of using simple script
```

Also you can create more comlex test script, using different groups, like this
```yml
  # script.yml
  - client: # first clients group
      multiplier: ":scale" # :scale take number from -s param, and run :scale number of clients in this group
      actions: # in case of using - client, all commands must be placed in actions: instead of root
        - receive: "Welcome"
        - wait_all # makes all clients in all groups wait untill every client get this point, after that they all continue
        - send:
            data: "test message"
  - client:
      multiplier: "10 * :scale" # also you can use arithmetic operations in this expression, so in case of :scale = 10, in this group started 100 clients
      actions:
        - receive: "Welcome"
        - wait_all
        - send:
            data: "test message"
```
After you get testing script you can run it by
```bash
wsdirector ws://websocket.server:9876 script.yml -s 10 # in case of using script with multiple clients
```

ActionCable example:

Channel code
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

Your testing script
```yml
# action.yml
# sending client script
- client:
    multiplier: ":scale"
    # Ignore ping messages
    ignore: !ruby/regexp /ping/
    actions:
      # welcome message from Action Cable
      - receive:
          data:
            type: "welcome"
      # subscribe on channel
      - send:
          data:
            command: "subscribe"
            identifier: "{\"channel\":\"ChatChannel\"}"
      # receive subscription confirmation
      - receive:
          data:
            identifier: "{\"channel\":\"ChatChannel\"}"
            type: "confirm_subscription"
      # now wait for all clients from all groups to get this point
      - wait_all
      # sending message in channel
      - send:
          data:
            command: "message"
            identifier: "{\"channel\":\"ChatChannel\"}"
            data: "{\"text\": \"hello\", \"action\":\"broadcast\"}"

# receiving client script
- client:
    # we want ten times as much clients
    multiplier: ":scale * 10"
    # you can add multiple ignore patterns
    ignore:
      - !ruby/regexp /ping/
    actions:
      # welcome from Action Cable
      - receive:
          data:
            type: "welcome"
      # subscribe on channel
      - send:
          data:
            command: "subscribe"
            identifier: "{\"channel\":\"ChatChannel\"}"
      # receive subscription confirmation
      - receive:
          data:
            identifier: "{\"channel\":\"ChatChannel\"}"
            type: "confirm_subscription"
      # now wait for all clients from all groups to get this point
      - wait_all
      # receive from channel message that was sending by first group
      - receive:
          data:
            identifier: "{\"channel\":\"ChatChannel\"}"
            message: # "{\"text\": \"hello\", \"action\"=>\"broadcast\"}"
              text: "hello"
              action: "broadcast"

```
and run it by
```bash
wsdirector action.yml ws://localhost:3000/cable -s 5
```

If all tests in all groups and clients passed, wsdirector will print success message,
otherwise it will print what groups fails, how many clients fails in this groups, relevant expecatations and really getting values, and exit with non-zero code.


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/palkan/wsdirector.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
