# test

## github.com/stretchr/testify

[github.com/stretchr/testify](https://github.com/stretchr/testify)

```bash
GO111MODULE=on go mod edit -require='github.com/stretchr/testify@v1.4.0'
GO111MODULE=on go mod vendor
```

fast use

```go
import (
  "testing"
  "github.com/stretchr/testify/assert"
)

func TestSomething(t *testing.T) {

  // assert equality
  assert.Equal(t, 123, 123, "they should be equal")

  // assert inequality
  assert.NotEqual(t, 123, 456, "they should not be equal")

  // assert for nil (good for errors)
  assert.Nil(t, object)

  // assert for not nil (good when you expect something)
  if assert.NotNil(t, object) {

    // now we know that object isn't nil, we are safe to make
    // further assertions without causing any errors
    assert.Equal(t, "Something", object.Value)

  }
}
```

# cron

[github.com/robfig/cron](https://github.com/robfig/cron)

```go
import (
	"github.com/robfig/cron/v3"
	"fmt"
)
func main() {
	c := cron.New()
	heartBitID, err := c.AddFunc("*/1 * * * *", func() {
		fmt.Printf("code at here to start cron each 1 min! now time: %v\n", time.Now().String())
	})
	c.Start()
	select {}
}
```

# depend

## github.com/bar-counter/monitor

[github.com/bar-counter/monitor](https://github.com/bar-counter/monitor)

```bash
GO111MODULE=on go mod edit -require=github.com/bar-counter/monitor@v1.1.0
GO111MODULE=on go mod vendor
```

## github.com/alecthomas/template

[github.com/alecthomas/template](https://github.com/alecthomas/template)

```bash
GO111MODULE=on go mod edit -require=github.com/alecthomas/template
GO111MODULE=on go mod vendor
```

## github.com/swaggo/gin-swagger

[github.com/swaggo/gin-swagger](https://github.com/swaggo/gin-swagger)

```bash
GO111MODULE=on go mod edit -require=github.com/swaggo/gin-swagger@master
GO111MODULE=on go mod vendor
```

## github.com/parnurzeal/gorequest

- api [https://gowalker.org/github.com/parnurzeal/gorequest](https://gowalker.org/github.com/parnurzeal/gorequest)
[https://godoc.org/github.com/parnurzeal/gorequest](https://godoc.org/github.com/parnurzeal/gorequest)
- source [https://github.com/parnurzeal/gorequest](https://github.com/parnurzeal/gorequest)

```bash
GO111MODULE=on go mod edit -require=github.com/parnurzeal/gorequest@v0.2.16
GO111MODULE=on go mod vendor
```

- use fast

```go
import (
	"github.com/parnurzeal/gorequest"
)

request := gorequest.New()
resp, body, errs := request.Get("http://example.com").
  RedirectPolicy(redirectPolicyFunc).
  Set("If-None-Match", `W/"wyzzy"`).
  End()

// PUT -> request.Put("http://example.com").End()
// DELETE -> request.Delete("http://example.com").End()
// HEAD -> request.Head("http://example.com").End()
// ANYTHING -> request.CustomMethod("TRACE", "http://example.com").End()
```

- json

```go
m := map[string]interface{}{
  "name": "backy",
  "species": "dog",
}
mJson, _ := json.Marshal(m)
contentReader := bytes.NewReader(mJson)
req, _ := http.NewRequest("POST", "http://example.com", contentReader)
req.Header.Set("Content-Type", "application/json")
req.Header.Set("Notes","GoRequest is coming!")
client := &http.Client{}
resp, _ := client.Do(req)
```

- Callback

```go
func printStatus(resp gorequest.Response, body string, errs []error){
  fmt.Println(resp.Status)
}
gorequest.New().Get("http://example.com").End(printStatus)
```
