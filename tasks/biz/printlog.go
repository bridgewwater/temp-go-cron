package biz

import (
	"github.com/bridgewwater/temp-go-cron/config"
	"time"
)

func PrintLogTask() func() {
	return func() {
		config.Sugar().Infof("code at here to start cron each 1 min! now time: %v", time.Now().String())
	}
}
