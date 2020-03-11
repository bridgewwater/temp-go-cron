# go-redis

## use

use see [https://github.com/go-redis/redis#quickstart](https://github.com/go-redis/redis#quickstart)

# config

## viper-config

```yaml
redis:
  addr: 127.0.0.1:6379
  db: 1
  is_no_pwd: true
  password: password
```

## depends

- [github.com/go-redis/redis](https://github.com/go-redis/redis)

```bash
dep ensure -add github.com/go-redis/redis@6.15.3
dep ensure -v
```

## initCode

```go
package model

import (
	"fmt"
	"github.com/go-redis/redis"
	"github.com/spf13/viper"
	"time"
)

const (
	defaultRedisMaxRetries   = 0
	defaultRedisDialTimeout  = 5 * time.Second
	defaultRedisReadTimeout  = 3 * time.Second
	defaultRedisWriteTimeout = defaultRedisReadTimeout
)

// init redis client
//	addr as localhost:6379
//	pwd if is "" will not use password
//	db redis db, default use 0
// use at code
//	initRedisClient(addr, password, db)
func initRedisClient(addr, pwd string, db int) (error, *redis.Client) {

	var opts *redis.Options
	if pwd == "" {
		opts = &redis.Options{
			Addr:         addr,
			DB:           db,
			MaxRetries:   defaultRedisMaxRetries,
			DialTimeout:  defaultRedisDialTimeout,
			ReadTimeout:  defaultRedisReadTimeout,
			WriteTimeout: defaultRedisWriteTimeout,
		}
	} else {
		opts = &redis.Options{
			Addr:         addr,
			Password:     pwd,
			DB:           db,
			MaxRetries:   defaultRedisMaxRetries,
			DialTimeout:  defaultRedisDialTimeout,
			ReadTimeout:  defaultRedisReadTimeout,
			WriteTimeout: defaultRedisWriteTimeout,
		}
	}
	redisClient := redis.NewClient(opts)
	_, err := redisClient.Ping().Result()
	if err != nil {
		return err, nil
	}
	return nil, redisClient
}

// init RedisByViper
// In config.yaml you can use as
//	redis:
//		addr: 127.0.0.1:6379
//		db: 1
//		is_no_pwd: false
//		password: 5290fb79983a8505
//	Warning!
//	if is_no_pwd true, wil not use password
//	if is_no_pwd false, will check redis.password not empty
func initRedisByViper() (error, *redis.Client) {
	addr := viper.GetString("redis.addr")
	if addr == "" {
		return fmt.Errorf("config file has not string at [ redis.addr ]"), nil
	}
	db := viper.GetInt("redis.db")
	noPwd := viper.GetBool("redis.is_no_pwd")
	if noPwd {
		return initRedisClient(addr, "", db)
	} else {
		password := viper.GetString("redis.password")
		if password == "" {
			return fmt.Errorf("config file [ is_no_pwd ] is true, but has not string at [ redis.password ]"), nil
		}
		return initRedisClient(addr, password, db)
	}
}

func removeRepeatedElementString(arr []string) (newArr []string) {
	newArr = make([]string, 0)
	for i := 0; i < len(arr); i++ {
		repeat := false
		for j := i + 1; j < len(arr); j++ {
			if arr[i] == arr[j] {
				repeat = true
				break
			}
		}
		if !repeat {
			newArr = append(newArr, arr[i])
		}
	}
	return
}

// scan keys instead redisCli.Keys()
//	redisCli *redis.Client
//	match string
//	maxCount int64
// return
//	error scan error
//	[]string removed repeated key
func RedisScanKeysMatch(redisCli *redis.Client, match string, maxCount int64) (error, []string) {
	var cursor uint64
	var scanFull []string
	for {
		keys, cursor, err := redisCli.Scan(cursor, match, maxCount).Result()
		if err != nil {
			return err, nil
		}
		if len(keys) > 0 {
			for _, v := range keys {
				scanFull = append(scanFull, v)
			}
		}
		if cursor == 0 {
			break
		}
	}
	scanRes := removeRepeatedElementString(scanFull)
	return nil, scanRes
}

```
