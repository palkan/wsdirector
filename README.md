# WebSocket Director

CLI for testing websocket, using scenarios.

<a href="https://evilmartians.com/">
<img src="https://evilmartians.com/badges/sponsored-by-evil-martians.svg" alt="Sponsored by Evil Martians" width="236" height="54"></a>

## Installation

```
gem install wsdirector
```

## Usage
```
wsdirector scenario path websocket_url  [-s]
```
If run was success it will print `success`
If something will go not according scenario, script returns fail exit code and print extra information.
There are 2 types of using: simple and multi-client
### Simple scenario
```yml
- receive:
    data:
      type: "welcome"
- send:
    data:
      command: "subscribe"
      identifier: "{\"channel\":\"TestChannel\"}"
- receive:
    data:
      identifier: "{\"channel\":\"TestChannel\"}"
      type: "confirm_subscription"
- send:
    data:
      command: "message"
      identifier: "{\"channel\":\"TestChannel\"}"
      data: "{\"text\": \"echo\",\"action\":\"echo\"}"
- receive:
    data:
      identifier: "{\"channel\":\"TestChannel\"}"
      message:
        text: "echo"
        action: "echo"
```
run simple scenario:
```
wsdirector script.yml ws://127.0.0.1:3000
```
### Multi-client scenario
```yml
- client: # first client group
    multiplier: ":scale"
    actions:
      - receive:
          data:
            type: "welcome"
      - send:
          data:
            command: "subscribe"
            identifier: "{\"channel\":\"TestChannel\"}"
      - receive:
          data:
            identifier: "{\"channel\":\"TestChannel\"}"
            type: "confirm_subscription"
      - wait_all
      - send:
          data:
            command: "message"
            identifier: "{\"channel\":\"TestChannel\"}"
            data: "{\"text\": \"echo\",\"action\":\"broadcast\"}"

- client: # second client group
    multiplier: ":scale * 2" # multiplies clients
    actions:
      - receive:
          data:
            type: "welcome"
      - send:
          data:
            command: "subscribe"
            identifier: "{\"channel\":\"TestChannel\"}"
      - receive:
          data:
            identifier: "{\"channel\":\"TestChannel\"}"
            type: "confirm_subscription"
      - wait_all # wait all clients in this point
      - receive:
          multiplier: ":scale" # multiplies actions
          data:
            identifier: "{\"channel\":\"TestChannel\"}"
            message:
              text: "echo"
              action: "broadcast"
```
`:scale` is multiplier of clients or actions. It pass by `-s` param. 

This example works with ActionCable channel:
```
class TestChannel < ApplicationCable::Channel
  def subscribed
    stream_from "all"
  end

  def echo(data)
    transmit data
  end

  def broadcast(data)
    ActionCable.server.broadcast "all", data
  end
end
```
run multi-client scenario:
```
wsdirector script.yml ws://127.0.0.1:3000 -s 5
```
## Development

```
bin/setup
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/palkan/wsdirector.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
