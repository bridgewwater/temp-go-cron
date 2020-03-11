## supervisor

daemon process by supervisor 

/etc/supervisor/conf.d/temp-go-cron.conf

```conf
[program:temp-go-cron]
autorestart=true
redirect_stderr=false
command=/root/Document/temp-go-cron/1.0.0/main -c /root/Document/temp-go-cron/1.0.0/config.yaml
stdout_logfile_maxbytes = 20MB
stdout_logfile_backups = 49
stdout_logfile = /root/Document/temp-go-cron/log/supervisor_stdout.log
stderr_logfile_maxbytes = 1MB
stderr_logfile_backups = 30
stderr_logfile = /root/Document/temp-go-cron/log/supervisor_stderr.log
```

redirect_stderr=true If true, the stderr log will be written to the stdout log file; default is false, it is not necessary to set

when update config use `supervisorctl update temp-go-cron`

- Effective

```bash
mkdir -p /root/Document/temp-go-cron/log/
# service supervisor restart
supervisorctl update

# check
supervisorctl status
tail -n 40 /root/Document/temp-go-cron/log/supervisor_stdout.log

tail -n 40 /root/Document/temp-go-cron/log/supervisor_stderr.log

# see more info
tail -f -n 30 /root/Document/temp-go-cron/log/supervisor_stdout.log

# update
cd [version]
cp config.yaml ~/Document/temp-go-cron/
supervisorctl stop temp-go-cron
cp main ~/Document/temp-go-cron/
supervisorctl update temp-go-cron
```

# supervisor-install

## centOS

```bash
yum check-update
yum install epel-release

yum search supervisor
yum install -y supervisor

systemctl enable supervisord
systemctl start supervisord

systemctl status supervisord
```

## ubuntu

```bash
apt-get install -y supervisord
```
