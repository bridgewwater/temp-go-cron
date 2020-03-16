package main

import (
	"fmt"
	"github.com/bridgewwater/temp-go-cron/config"
	"github.com/robfig/cron/v3"
	"github.com/spf13/pflag"
	"time"
)

var (
	cfg = pflag.StringP("config", "c", "", "api server config file path.")
)

// @termsOfService http://github.cm/
// @contact.name API Support
// @contact.url http://github.cm/
// @contact.email support@github.cm
// @license.name Apache 2.0
// @license.url http://www.apache.org/licenses/LICENSE-2.0.html
func main() {
	pflag.Parse()

	// init config
	if err := config.Init(*cfg); err != nil {
		fmt.Printf("Error, run service not use -c or config yaml error, more info: %v\n", err)
		panic(err)
	}
	c := cron.New()
	heartBitID, err := c.AddFunc("*/1 * * * *", func() {
		config.Sugar().Debugf("code at here to start cron each 1 min! now time: %v", time.Now().String())
	})
	if err != nil {
		config.Sugar().Errorf("init cron error err: %v", err)
		panic(err)
	}
	config.Sugar().Infof("heartBitID run at %v", heartBitID)
	c.Start()
	select {}
}
