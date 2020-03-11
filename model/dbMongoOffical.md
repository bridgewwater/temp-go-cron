# use lib

- [mongodb office document](https://docs.mongodb.com/ecosystem/drivers/go/)
- [github url https://github.com/mongodb/mongo-go-driver](https://github.com/mongodb/mongo-go-driver#usage)
- [doc go.mongodb.org/mongo-driver/mongo](https://godoc.org/go.mongodb.org/mongo-driver/mongo)
- [doc go.mongodb.org/mongo-driver/bson](https://godoc.org/go.mongodb.org/mongo-driver/bson)
- [example.go](https://github.com/mongodb/mongo-go-driver/blob/master/examples/documentation_examples/examples.go)


# mongo-bson

- `bson.D`: A BSON document. This type should be used in situations where order matters, such as MongoDB commands.
- `bson.M`: An unordered map. It is the same as D, except it does not preserve order.
- `bson.A`: A BSON array.
- `bson.E`: A single element inside a D.

e.g.

```go
bson.D{{
    "name",
    bson.D{{
        "$in",
        bson.A{"Alice", "Bob"}
    }}
}}
```

# use

## Collection

```go
import (
	"github.com/gin-gonic/gin"
	"xx/model"
)

func Base(c *gin.Context) {
	database := model.GetMongoDatabase()
	auth := database.Collection("auth")
}
```

## insert

```go
	if result, err := auth.InsertOne(ctx, Response{
		Code:    200,
		Message: "1233",
	}); err != nil {
		log.Debugf("InsertOne Database %v Error: %v", database.Name(), err)
		//return &mongo.Client{}, &mongo.Database{}, err
	} else {
		log.Debugf("InsertOne Database %v id: %v", database.Name(), result.InsertedID)
	}

	cursor, err := database.ListCollections(ctx, command.ListCollections{}, )
	if err != nil {
		log.Errorf(err, "ListCollections mongoDB error at: %v with %v", mongoUri, err)
		return nil, nil, err
	}
	for cursor.Next(ctx) {
		id := cursor.ID()
		s := cursor.Current.String()
		log.Debugf("ListCollections id: %v, current: %v", id, s)
	}
```

# initCode

## config-by init.go

```yaml
mongo:
  addr: localhost:27018
  db: golang
  user: dev4
  pwd: passwd
  time_out: 10
```

## connect and base test

- most use at main.go, before gin init

```go
import (
	"xx/model"
)
	model.DB.Init()
	defer model.DB.Close()
```

> this method only check connect and ping, if user

## init-code

- in pkg `module`

```go
import (
	"context"
	"fmt"
	"github.com/spf13/viper"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"go.mongodb.org/mongo-driver/mongo/readpref"
	"net/url"
	"time"
)

const defaultMongoAuthMechanism string = "SCRAM-SHA-256"

// mongodb://user:password@localhost:27017/db
//	username user name of mongodb
//	password password of mongodb
//	addr  address of mongodb must has port
//	dbName database name of mongodb
//	timeOutSecond connect time out of mongodb
// return *mongo.Client, *mongo.Database, then error
func openMongo(authMechanism, username, password, addr, dbName string, timeOutSecond int) (*mongo.Client, *mongo.Database, error) {
	var mongoUri = fmt.Sprintf("mongodb://%v:%v@%v/%v", username, password, addr, dbName)
	mongoUrl, err := url.Parse(mongoUri)
	if err != nil {
		return nil, nil, fmt.Errorf("connect mongo string error at: %v with %v", mongoUri, err.Error())
	}

	// can use other log
	log.Infof("Try connect mongo: %v", mongoUri)

	//set Auth, this is must
	opts := &options.ClientOptions{}
	opts.SetAuth(options.Credential{
		AuthMechanism: authMechanism,
		AuthSource:    dbName,
		Username:      username,
		Password:      password,
	})
	client, err := mongo.NewClient(options.Client().ApplyURI(mongoUri), opts)
	if err != nil {
		return nil, nil, fmt.Errorf("new mongo client error at: %v with %v", mongoUri, err.Error())
	}

	ctx, _ := context.WithTimeout(context.Background(), time.Duration(timeOutSecond)*time.Second)

	err = client.Connect(ctx)
	if err != nil {
		return nil, nil, fmt.Errorf("connect mongoDB error at: %v with %v", mongoUri, err.Error())
	}

	// test ping
	if err := client.Ping(ctx, readpref.Primary()); err != nil {
		return nil, nil, fmt.Errorf("ping mongoDB error at: %v with %v", mongoUri, err.Error())
	}

	database := client.Database(mongoUrl.Path[1:])

	// can use other log
	log.Infof("Open and ping mongoDB success at: %v", mongoUri)
	log.Infof("If want use CLI: mongo --authenticationMechanism %v --authenticationDatabase %v -u %v -p %v %v",
		authMechanism, dbName, username, password, addr)
	// cancel function by ctx
	return client, database, nil
}

// mongodb://localhost:27017/db
//	addr  address of mongodb must has port
//	dbName database name of mongodb
//	timeOutSecond connect time out of mongodb
// return *mongo.Client, *mongo.Database, then error
func openMongoNoPwd(addr, dbName string, timeOutSecond int) (*mongo.Client, *mongo.Database, error) {
	var mongoUri = fmt.Sprintf("mongodb://%v/%v", addr, dbName)
	mongoUrl, err := url.Parse(mongoUri)
	if err != nil {
		return nil, nil, fmt.Errorf("connect mongo string error at: %v with %v", mongoUri, err.Error())
	}

	// can use other log
	log.Infof("Try connect No password mongo: %v", mongoUri)

	client, err := mongo.NewClient(options.Client().ApplyURI(mongoUri))
	if err != nil {
		return nil, nil, fmt.Errorf("new mongo No password client error at: %v with %v", mongoUri, err.Error())
	}

	ctx, _ := context.WithTimeout(context.Background(), time.Duration(timeOutSecond)*time.Second)

	err = client.Connect(ctx)
	if err != nil {
		return nil, nil, fmt.Errorf("connect No password mongoDB error at: %v with %v", mongoUri, err.Error())
	}

	// test ping
	if err := client.Ping(ctx, readpref.Primary()); err != nil {
		return nil, nil, fmt.Errorf("ping No password mongoDB error at: %v with %v", mongoUri, err.Error())
	}

	database := client.Database(mongoUrl.Path[1:])

	// can use other log
	log.Debugf("Try open No password mongoDB Database at: %v", database.Name())
	log.Infof("Open and ping No password mongoDB success at: %v", mongoUri)
	log.Infof("If want use CLI: mongo %v/%v", addr, dbName)
	// cancel function by context
	return client, database, nil
}

// init mongoDB by yaml with viper
// viper config.yaml like
//	mongo:
//	addr: 47.112.118.101:27018
//	time_out: 10              # time out unit is second
//	no_pwd: false             # true or false no need pwd
//	auth_mechanism: SCRAM-SHA-1             # default is SCRAM-SHA-256
//	db: dbName                # name of connect db
//	user: user                # effective no_pwd is false
//	pwd: userPwd           # effective no_pwd is false
func initMongoDBByViper() (*mongo.Client, *mongo.Database) {
	noPwd := viper.GetBool("mongo.no_pwd")
	if noPwd {
		client, db, err := openMongoNoPwd(
			viper.GetString("mongo.addr"),
			viper.GetString("mongo.db"),
			viper.GetInt("mongo.time_out"),
		)
		if err != nil {
			panic(err)
		}
		return client, db
	} else {

		authMechanism := viper.GetString("mongo.auth_mechanism")
		if authMechanism == "" {
			authMechanism = defaultMongoAuthMechanism
		}
		client, db, err := openMongo(
			authMechanism,
			viper.GetString("mongo.user"),
			viper.GetString("mongo.pwd"),
			viper.GetString("mongo.addr"),
			viper.GetString("mongo.db"),
			viper.GetInt("mongo.time_out"),
		)
		if err != nil {
			panic(err)
		}
		return client, db
	}

}
```
