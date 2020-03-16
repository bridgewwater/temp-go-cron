package config

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/spf13/viper"
)

const (
	// env prefix is web
	defaultEnvPrefix string = "ENV_CRON"
	// env ENV_CRON_HTTPS_ENABLE default false
	defaultEnvHttpsEnable string = "HTTPS_ENABLE"
	// env ENV_CRON_HOST default ""
	defaultEnvHost string = "HOST"
	// env ENV_AUTO_HOST default true
	defaultEnvAutoGetHost string = "AUTO_HOST"
)

var mustConfigString = []string{
	"runmode",
	"addr",
	"name",
	"base_path",
	// project set
}

type Config struct {
	Name string
}

// read default config by conf/config.yaml
// can change by CLI by `-c`
// this config can config by ENV
//	ENV_CRON_HTTPS_ENABLE=false
//	ENV_AUTO_HOST=true
//	ENV_CRON_HOST 127.0.0.1:8000
func Init(cfg string) error {
	c := Config{
		Name: cfg,
	}

	// initialize configuration file
	if err := c.initConfig(); err != nil {
		return err
	}

	// initialization log package
	if err := c.initLog(); err != nil {
		return err
	}

	// init BaseConf
	initBaseConf()

	// TODO other config

	// monitor configuration changes and hot loaders
	c.watchConfig()

	return nil
}

func (c *Config) initConfig() error {
	if c.Name != "" {
		viper.SetConfigFile(c.Name) // If a configuration file is specified, the specified configuration file is parsed
		exists, err := pathExists(c.Name)
		if err != nil {
			return err
		}
		if !exists {
			return fmt.Errorf("can not found config file at: %v", c.Name)
		}
	} else {
		viper.AddConfigPath(filepath.Join("conf")) // If no configuration file is specified, the default configuration file is conf/config.yaml
		viper.SetConfigName("config")
	}
	viper.SetConfigType("yaml")          // Set the configuration file format to YAML
	viper.AutomaticEnv()                 // Read matching environment variables
	viper.SetEnvPrefix(defaultEnvPrefix) // Read environment variables with the prefix defaultEnvPrefix

	// Set default read environment variables
	_ = os.Setenv(defaultEnvHost, "")
	_ = os.Setenv(defaultEnvHttpsEnable, "false")
	_ = os.Setenv(defaultEnvAutoGetHost, "true")

	replacer := strings.NewReplacer(".", "_")
	viper.SetEnvKeyReplacer(replacer)
	if err := viper.ReadInConfig(); err != nil { // viper read
		return err
	}

	if err := checkMustHasString(); err != nil {
		return err
	}

	return nil
}

// check config.yaml must has string key
//	config.mustConfigString
func checkMustHasString() error {
	for _, config := range mustConfigString {
		if "" == viper.GetString(config) {
			return fmt.Errorf("not has must string key [ %v ]", config)
		}
	}
	return nil
}

func pathExists(path string) (bool, error) {
	_, err := os.Stat(path)
	if err == nil {
		return true, nil
	}
	if os.IsNotExist(err) {
		return false, nil
	}
	return false, err
}
