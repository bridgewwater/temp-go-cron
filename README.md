## for what

- this project used to gin api server
- [ ] rename `github.com/bridgewwater/temp-go-cron` to your api package name

## use

- `need go mod to management golang dependenceis`

> change [Makefile](Makefile) `ENV_NEED_PROXY=1` to open proxy

```sh
$ make help

# check base dep
$ make init
# first run just use dep to get dep
$ make dep
# change conf/config.yaml

# run server as dev
$ make dev

# run in docker
# has two mod code run and less binary run
# docker code run use
$ make dockerLocalFileRest dockerBuildRun
# docker binary run
$ make dockerLocalFileLess dockerLessBuild dockerLessBuildRun
```

most of doc at [http://127.0.0.1:39000/swagger/index.html](http://127.0.0.1:39000/swagger/index.html)

# dev

> if want auto get local IP for fast develop, you can add evn `ENV_CRON_AUTO_HOST=true`

- each new swagger must rebuild swagger doc by task `make buildSwagger`
- also use task `make dev` or `make runTest` also run task buildSwagger before.
- swagger tools use [swag](https://github.com/swaggo/swag)
```sh
go get -v -u github.com/swaggo/swag/cmd/swag
```

- swagger doc see [https://swaggo.github.io/swaggo.io/declarative_comments_format/](https://swaggo.github.io/swaggo.io/declarative_comments_format/)
- swagger example see [https://github.com/swaggo/swag/blob/master/example/basic/api/api.go](https://github.com/swaggo/swag/blob/master/example/basic/api/api.go)

## evn

```bash
go version go1.11.4 darwin/amd64
gin version 1.3.0
swag version v1.4.1
```

# config

- If a configuration file is specified, the specified configuration file is parsed
- config file is `config.yaml` demo see [conf/config.yaml](conf/config.yaml)
- If no configuration file is specified, the default configuration file is conf/config.yaml

## log

```yaml
zap:
  AtomicLevel: -1 # DebugLevel:-1 InfoLevel:0 WarnLevel:1 ErrorLevel:2
  FieldsAuto: false # is use auto Fields key set
  Fields:
    Key: key
    Val: val
  Development: true # is open Open file and line number
  Encoding: console # output format, only use console or json, default is console
  rotate:
    Filename: log/go-cron.log # Log file path
    MaxSize: 16 # Maximum size of each log file, Unit: M
    MaxBackups: 10 # How many backups are saved in the log file
    MaxAge: 7 # How many days can the file be keep, Unit: day
    Compress: true # need compress
  EncoderConfig:
    TimeKey: time
    LevelKey: level
    NameKey: logger
    CallerKey: caller
    MessageKey: msg
    StacktraceKey: stacktrace
```

## folder-Def

```

```
