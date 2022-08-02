# Change log

## master

- Add `--subprotocol` support and `connection_options` in the scenario files. ([@palkan][])

- Add `-f/--file` option to specify scenario path. ([@palkan][])

- Drop Ruby 2.5 support.

## 0.5.0 (2021-10-13)

- Add JSON support. ([@wazzuper][])

- Add new commands to CLI.

You can pass a JSON scenario directly to the CLI without creating a file:

```bash
wsdirector -i '[{"receive": {"data":"welcome"}},{"send":{"data":"send message"}},{"receive":{"data":"receive message"}}]' -u ws://websocket.server:9876
```

or you can pass it as a JSON file:

```bash
wsdirector scenario.json -u ws://websocket.server:9876
```

- Add loop option support. ([@last-in-japan][])

You can specify a `loop` option to perform a similar set of actions multiple times:

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

Useful in combination with `:scale`.

## 0.4.0 (2020-08-24)

- **Drop Ruby 2.4 support**. ([@palkan][])

- Add sampling support. ([@palkan][])

You can specify a `sample` option for a step to only run this step by specified number of clients from the group:

```yml
- perform:
  sample: ":scale / 2"
  channel: "chat"
  params:
    id: 2
  action: "speak"
  data:
    message: "Hello!"
```

Useful in combination with `:scale`.

**NOTE:** Sample size is always greater or equal to 1.

- Add ERB support. ([@palkan][])

Now you can, for example, access `ENV` from scenarios.

## 0.3.0 (2018-05-02)

- Add `debug` action and options. ([@palkan][])

Allows to print arbitrary messages during the execution.

- Add `sleep` action. ([@palkan][])

- Add `receive_all` action. ([@palkan][])

Allows to handle multiple messages with unspecified order:

```yml
- receive_all:
    messages:
      - data:
          text: "Hello!"
        multiplier: ":scale + :scale"
        channel: "chat"
        params:
          id: 2
      - data:
          text: "message sent"
        channel: "chat"
        params:
          id: 2
```

## 0.2.0 (2017-11-05)

- Initial version. ([@palkan][], [@Kirillvs][], [@Grandman][])

[@palkan]: https://github.com/palkan
[@Kirillvs]: https://github.com/Kirillvs
[@Grandman]: https://github.com/Grandman
[@wazzuper]: https://github.com/wazzuper
[@last-in-japan]: https://github.com/last-in-japan
