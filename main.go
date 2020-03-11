package main

import (
	"fmt"
	"github.com/bridgewwater/temp-go-cron/config"
	"github.com/spf13/pflag"
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
}
