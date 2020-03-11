## config

```yaml
monitor: # monitor
  status: true             # api status use {monitor.health}
  health: /status/health   # api health
  retryCount: 10           # ping api health retry count
  hardware: false           # hardware true or false
  status_hardware:
    disk: /status/hardware/disk     # hardware api disk
    cpu: /status/hardware/cpu       # hardware api cpu
    ram: /status/hardware/ram       # hardware api ram
  debug: false                       # debug true or false
  pprof: false                       # security true or false
  security: true                    # debug and security security true or false
  securityUser:
    admin: # admin:pwd
```

- `http://127.0.0.1:39000` change by actual environment

## health

```bash
curl http://127.0.0.1:39000/status/health \
	-X GET
```

## disk

```bash
curl http://127.0.0.1:39000/status/hardware/disk \
	-X GET
```

## cpu

```bash
curl http://127.0.0.1:39000/status/hardware/cpu \
	-X GET
```

## ram

```bash
curl http://127.0.0.1:39000/status/hardware/ram \
	-X GET
```
