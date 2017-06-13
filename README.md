# WebSocket Director

Command line tool for testing websocket servers.

Suitable for testing any websocket server implementation, like [Action Cable](https://github.com/rails/rails/tree/master/actioncable), [Websocket Eventmachine Server](https://github.com/imanel/websocket-eventmachine-server), [Litecable](https://github.com/palkan/litecable) and so on.
Also can be used for stress testing.

<a href="https://evilmartians.com/">
<img src="https://evilmartians.com/badges/sponsored-by-evil-martians.svg" alt="Sponsored by Evil Martians" width="236" height="54"></a>

## Installation

```ruby
  $ gem install wsdirector
```

## Usage

Create yaml file with simle testing script, like that

```yml
  - receive: "Welcome" # expect to receive message
  - send:
      data: "send message" # send message, all messages in data will be parse to json
  - receive:
      data: "receive message" # expect to receive json message
```
Also you can create more comlex test script, using different groups, like this
```yml
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
wsdirector ws://websocket.server:9876 script.yml # in case of using simple script
```
or
```bash
wsdirector ws://websocket.server:9876 script.yml -s 10 # in case of using script with multiple clients
```

If all tests in all groups and clients passed, wsdirector will print success message,
otherwise it will print what groups fails, how many clients fails in this groups, and relevant expecatations and really getting values.

## Development

```bash
bin/setup
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/palkan/WSdirector.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
