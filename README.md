## for what

- this project used to gin api server
- [ ] rename `github.com/bridgewwater/temp-go-cron` to your api package name

## use

- `need go mod to management golang dependenceis`

```sh
$ make help
# check base dep
$ make init
# first run just use dep to get dep
$ make dep
# change conf/config.yaml

# run server as dev
$ make dev
# run as docker contant
$ make dockerRunLinux
# if use macOS
$ make dockerRunDarwin
# stop or remove docker
$ make dockerStop
$ make dockerRemove
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
log:
  writers: file,stdout            # file,stdout。`file` will let `logger_file` to file，`stdout` will show at std, most of time use bose
  logger_level: DEBUG             # log level: DEBUG, INFO, WARN, ERROR, FATAL
  logger_file: log/cron.log     # log file setting
  log_format_text: false          # format `false` will format json, `true` will show abs
  rollingPolicy: size             # rotate policy, can choose as: daily, size. `daily` store as daily，`size` will save as max
  log_rotate_date: 1              # rotate date, coordinate `rollingPolicy: daily`
  log_rotate_size: 8              # rotate size，coordinate `rollingPolicy: size`
  log_backup_count: 7             # backup max count, log system will compress the log file when log reaches rotate set, this set is max file count
```

## folder-Def

```

```
