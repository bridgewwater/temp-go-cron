# this file must use as base Makefile

modVerify:
	# in GOPATH must use [ GO111MODULE=on go mod ] to use
	-if [ $(ENV_NEED_PROXY) -eq 1 ]; \
	then GOPROXY="$(ENV_GO_PROXY)" GO111MODULE=on go mod verify; \
	else GO111MODULE=on go mod verify; \
	fi

modDownload:
	-if [ $(ENV_NEED_PROXY) -eq 1 ]; \
	then GOPROXY="$(ENV_GO_PROXY)" GO111MODULE=on go mod download && GOPROXY="$(ENV_GO_PROXY)" GO111MODULE=on go mod vendor; \
	else GO111MODULE=on go mod download && GO111MODULE=on go mod vendor; \
	fi

modTidy:
	-if [ $(ENV_NEED_PROXY) -eq 1 ]; \
	then GOPROXY="$(ENV_GO_PROXY)" GO111MODULE=on go mod tidy; \
	else GO111MODULE=on go mod tidy; \
	fi

dep: modVerify modDownload
	@echo "just check depends info below"

modGraphDependencies:
	-if [ $(ENV_NEED_PROXY) -eq 1 ]; \
	then GOPROXY="$(ENV_GO_PROXY)" GO111MODULE=on go mod graph; \
	else GO111MODULE=on go mod graph; \
	fi

helpGoMod:
	@echo "Help: MakeGoMod.mk"
	@echo "this project use go mod, so golang version must 1.12+"
	@echo "go mod evn: GOPROXY=$(ENV_GO_PROXY)"
	@echo "~> make dep - check depends of project and download all, child task is: modVerify modDownload"
	@echo "~> make modGraphDependencies - see depends graph of this project"
	@echo "~> make modTidy - tidy depends graph of project"
	@echo ""