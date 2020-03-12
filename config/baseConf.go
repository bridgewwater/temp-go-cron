package config

import (
	"fmt"
	"github.com/bridgewwater/temp-go-cron/util/sys"
	"github.com/sinlovgo/log"
	"github.com/spf13/viper"
	"net/url"
	"strings"
)

var baseConf BaseConf

type BaseConf struct {
	BaseURL   string
	SSLEnable bool
}

func BaseURL() string {
	return baseConf.BaseURL
}

// read default config by conf/config.yaml
// can change by CLI by `-c`
// this config can config by ENV
//	ENV_CRON_HTTPS_ENABLE=false
//	ENV_AUTO_HOST=true
//	ENV_CRON_HOST 127.0.0.1:8000
func initBaseConf() {
	ssLEnable := false
	if viper.GetBool(defaultEnvHttpsEnable) {
		ssLEnable = true
	} else {
		ssLEnable = viper.GetBool("sslEnable")
	}
	runMode := viper.GetString("runmode")
	var apiBase string
	if "debug" == runMode {
		apiBase = viper.GetString("dev_url")
	} else if "test" == runMode {
		apiBase = viper.GetString("test_url")
	} else {
		apiBase = viper.GetString("prod_url")
	}

	uri, err := url.Parse(apiBase)
	if err != nil {
		panic(err)
	}

	baseHOSTByEnv := viper.GetString(defaultEnvHost)
	if baseHOSTByEnv != "" {
		uri.Host = baseHOSTByEnv
		apiBase = uri.String()
	} else {
		isAutoHost := viper.GetBool(defaultEnvAutoGetHost)
		log.Debugf("isAutoHost %v", isAutoHost)
		if isAutoHost {
			ipv4, err := sys.NetworkLocalIP()
			if err == nil {
				addrStr := viper.GetString("addr")
				var proc string
				if ssLEnable {
					proc = "https"
				} else {
					proc = "http"
				}
				apiBase = fmt.Sprintf("%v://%v%v", proc, ipv4, addrStr)
			}
		}
	}

	if ssLEnable {
		apiBase = strings.Replace(apiBase, "http://", "https://", 1)
	}
	log.Debugf("config file uri.Host %v", uri.Host)
	log.Debugf("apiBase %v", apiBase)
	baseConf = BaseConf{
		BaseURL:   apiBase,
		SSLEnable: ssLEnable,
	}
}
