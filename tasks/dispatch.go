package tasks

import (
	"github.com/bridgewwater/temp-go-cron/config"
	"github.com/bridgewwater/temp-go-cron/tasks/biz"
	"github.com/robfig/cron/v3"
)

func InitDispatch() error {
	c := cron.New()
	err := bizTask(c)
	if err != nil {
		return err
	}

	c.Start()
	select {}
}

func bizTask(c *cron.Cron) error {
	heartBitID, err := c.AddFunc("*/1 * * * *", biz.PrintLogTask())
	if err != nil {
		return err
	}
	config.Sugar().Infof("heartBitID run at %v", heartBitID)
	return nil
}
