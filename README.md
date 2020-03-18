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

# dev

> if want auto get local IP for fast develop, you can add evn `ENV_CRON_AUTO_HOST=true`

## evn

```bash
go version go1.13.x darwin/amd64
github.com/robfig/cron/v3 v3.0.1
github.com/spf13/viper v1.6.2
go.uber.org/zap v1.10.0
gopkg.in/natefinch/lumberjack.v2 v2.0.0
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
    Filename: log/temp-go-cron.log # Log file path
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

# cli tools to init project fast

```
$ curl -L --fail https://raw.githubusercontent.com/bridgewwater/temp-go-cron/master/temp-go-cron
# let temp-go-cron file folder under $PATH
$ chmod +x temp-go-cron
# see how to use
$ temp-go-cron -h
```

## folder-Def

```
.
├── Dockerfile # will change by make dockerLocalFileRest or make dockerLocalFileLess
├── LIB.md
├── LICENCE
├── MakeDockerRun.mk
├── MakeGoMod.mk
├── Makefile
├── README.md
├── conf    # conf file folder 
│   ├── config.yaml
│   ├── release # realse use docker build use to
│   │   ├── config.yaml
│   │   └── docker-compose.yml # will change by make dockerLocalFileLess
│   └── test # test use
│       ├── config.yaml
│       └── docker-compose.yml
├── config  # golang pkg for project config log at here
│   ├── baseConf.go
│   ├── config.go
│   ├── logConf.go
│   └── watchConf.go
├── doc # doc folder
│   ├── README.md
│   ├── monitor.md
│   ├── supervisor.md
│   └── systemctl.md
├── docker
│   └── alpine # apline build helper script
│       ├── build-tag.sh
│       └── rest-build-tag.sh
├── docker-compose.yml  # will change by make dockerLocalFileRest or make dockerLocalFileLess
├── go.mod
├── go.sum
├── log # dev log folder
├── main.go # enter of project
├── model # golang pkg model templete
│   ├── biz
│   │   └── biz.go
│   ├── dbMongoOffical.md
│   ├── dbRedis.md
│   └── response.go
├── pkg # golang pkg
├── tasks # golang pkg tasks for cron
│   ├── biz # task group biz
│   │   └── printlog.go
│   └── dispatch.go # dispatch of cron
├── temp-golang-cron # script shell for fast build project
└── util # golang pkg util
    ├── folder
    │   └── path.go
    └── sys
        ├── network.go
        └── network_test.go
```
