## systemctl

daemon process by systemctl

/lib/systemd/system/temp-go-cron.service

```conf
[Unit]
Description=temp-go-cron web service
After=network-online.target network.target syslog.target
Wants=network.target

[Service]
Type=simple
# start path need change
ExecStart=/root/api/api-swtich-subscription/1.0.0/main -c /root/api/api-swtich-subscription/1.0.0/config.yaml
# auto restart open, default is no, other is always on-success
Restart=always
# auto restart time default is 0.1s
RestartSec=5
# auto restart count 0 is unlimited
StartLimitInterval=10
# if ExitStatus 143 137 SIGTERM SIGKILL will not restart
#RestartPreventExitStatus=143 137 SIGTERM SIGKILL

[Install]
WantedBy=multi-user.target
```

when update config use  `supervisorctl update temp-go-cron`

- Effective

```sh
# run log
journalctl -u temp-go-cron
# status of service
sudo systemctl status temp-go-cron

# must reload when change config
sudo systemctl daemon-reload
sudo systemctl restart temp-go-cron

# test run
sudo systemctl start temp-go-cron
# stop
sudo systemctl stop temp-go-cron
# enable system start when pass test
sudo systemctl enable temp-go-cron

# update
cd [version]
cp config.yaml ~/api/api-swtich-subscription/
supervisorctl stop temp-go-cron
cp [new file] ~/api/api-swtich-subscription/
supervisorctl update temp-go-cron
```

## log setting

```bash
# see log
systemctl list-units | grep journal*
```
