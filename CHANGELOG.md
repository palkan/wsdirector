# Change log

## master

- Added `receive_all` action. ([@palkan][])

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
