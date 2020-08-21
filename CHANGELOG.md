# Change log

## master

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
