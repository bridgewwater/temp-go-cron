# this file must use as base Makefile

# use Makefile ROOT_NAME
ROOT_DOCKER_CONTAINER_NAME ?= $(ROOT_NAME)
ROOT_DOCKER_CONTAINER_PORT ?= 39000
# change this for docker parent
ROOT_DOCKER_IMAGE_PARENT_NAME ?= golang # do not change
ROOT_DOCKER_IMAGE_PARENT_TAG ?= 1.13.8-alpine # see https://hub.docker.com/_/golang must use alpine
ROOT_BUILD_DOCKER_IMAGE_NAME=alpine # do not change
ROOT_BUILD_DOCKER_IMAGE_TAG=3.10 # https://hub.docker.com/_/alpine
# change this for dockerRunLinux or dockerRunDarwin
ROOT_DOCKER_IMAGE_NAME ?= $(ROOT_NAME)
# can change as local set or read Makefile ENV_DIST_VERSION
ROOT_DOCKER_IMAGE_TAG ?= $(ENV_DIST_VERSION)
ROOT_DOCKER_IMAGE_TAG_MK_OUT ?= go-cron-bin # will change less build out bin name

ROOT_DOCKER_IMAGE_TAG_MK_FOLDER ?= docker/alpine # do not change

# For Docker dev images init task
initDockerImagesMod:
	@echo "~> start init this project in docker"
	@echo "-> check version"
	go version
	@echo "-> check env golang"
	go env
	-if [ $(ENV_NEED_PROXY) -eq 1 ]; \
	then GOPROXY="$(ENV_GO_PROXY)" GO111MODULE=on go mod download && GOPROXY="$(ENV_GO_PROXY)" GO111MODULE=on go mod vendor; \
	else GO111MODULE=on go mod download && GO111MODULE=on go mod vendor; \
	fi

dockerLocalFileRest:
	cd $(ROOT_DOCKER_IMAGE_TAG_MK_FOLDER) && \
	if [ $(ENV_NEED_PROXY) -eq 1 ]; \
	then bash rest-build-tag.sh -p -b $(ENV_DIST_VERSION) -b $(ENV_DIST_VERSION) -n $(ROOT_NAME) -i $(ROOT_DOCKER_IMAGE_PARENT_TAG); \
	else bash rest-build-tag.sh -b $(ENV_DIST_VERSION) -n $(ROOT_NAME) -i $(ROOT_DOCKER_IMAGE_PARENT_TAG); \
	fi

dockerLocalFileLess:
	cd $(ROOT_DOCKER_IMAGE_TAG_MK_FOLDER) && \
	if [ $(ENV_NEED_PROXY) -eq 1 ]; \
	then bash build-tag.sh -p -b $(ENV_DIST_VERSION) -n $(ROOT_NAME) -i $(ROOT_DOCKER_IMAGE_PARENT_TAG) -r $(ROOT_DOCKER_IMAGE_TAG_MK_OUT) -z $(ROOT_BUILD_DOCKER_IMAGE_TAG); \
	else bash build-tag.sh -b $(ENV_DIST_VERSION) -n $(ROOT_NAME) -i $(ROOT_DOCKER_IMAGE_PARENT_TAG) -r $(ROOT_DOCKER_IMAGE_TAG_MK_OUT) -z $(ROOT_BUILD_DOCKER_IMAGE_TAG); \
	fi

dockerLocalImageBuildFile: initDockerImagesMod
	if [ $(ENV_NEED_PROXY) -eq 1 ]; \
	then GOPROXY="$(ENV_GO_PROXY)" CGO_ENABLED=0 go build -tags netgo -a -installsuffix cgo -ldflags '-w' -i -o $(ROOT_DOCKER_IMAGE_TAG_MK_OUT) main.go; \
	else CGO_ENABLED=0 go build -tags netgo -a -installsuffix cgo -ldflags '-w' -i -o $(ROOT_DOCKER_IMAGE_TAG_MK_OUT) main.go; \
	fi

dockerLocalImageRemove:
	-docker image rm -f $(ROOT_DOCKER_IMAGE_NAME):$(ROOT_DOCKER_IMAGE_TAG)

dockerLocalImageRebuild: dockerLocalImageRemove
	docker build --tag $(ROOT_DOCKER_IMAGE_NAME):$(ROOT_DOCKER_IMAGE_TAG) .

dockerRun:
	-docker image inspect --format='{{ .Created}}' $(ROOT_DOCKER_IMAGE_NAME):$(ROOT_DOCKER_IMAGE_TAG)
	ENV_CRON_HOST=0.0.0.0 \
	ENV_CRON_PORT=$(ROOT_DOCKER_CONTAINER_PORT) \
	ROOT_NAME=$(ROOT_DOCKER_IMAGE_NAME) \
	DIST_TAG=$(ROOT_DOCKER_IMAGE_TAG) \
	docker-compose up -d
	-sleep 5
	@echo "=> container $(ROOT_DOCKER_CONTAINER_NAME) now status"
	docker inspect --format='{{ .State.Status}}' $(ROOT_DOCKER_CONTAINER_NAME)
	@echo "=> see log with: docker logs $(ROOT_DOCKER_CONTAINER_NAME) -f"

localIPLinux:
	@echo "=> now run as docker with linux"
	@echo "local ip address is: $(ROOT_LOCAL_IP_V4_LINUX)"

dockerRunLinux: localIPLinux
	-docker image inspect --format='{{ .Created}}' $(ROOT_DOCKER_IMAGE_NAME):$(ROOT_DOCKER_IMAGE_TAG)
	ENV_CRON_HOST=$(ROOT_LOCAL_IP_V4_LINUX) \
	ENV_CRON_PORT=$(ROOT_DOCKER_CONTAINER_PORT) \
	ROOT_NAME=$(ROOT_DOCKER_IMAGE_NAME) \
	DIST_TAG=$(ROOT_DOCKER_IMAGE_TAG) \
	docker-compose up -d
	-sleep 5
	@echo "=> container $(ROOT_DOCKER_CONTAINER_NAME) now status"
	docker inspect --format='{{ .State.Status}}' $(ROOT_DOCKER_CONTAINER_NAME)
	@echo "=> see log with: docker logs $(ROOT_DOCKER_CONTAINER_NAME) -f"

dockerRestartLinux: localIPLinux
	docker inspect --format='{{ .State.Status}}' $(ROOT_DOCKER_IMAGE_NAME)
	ENV_CRON_HOST=$(ROOT_LOCAL_IP_V4_LINUX) \
	ENV_CRON_PORT=$(ROOT_DOCKER_CONTAINER_PORT) \
	ROOT_NAME=$(ROOT_DOCKER_IMAGE_NAME) \
	DIST_TAG=$(ROOT_DOCKER_IMAGE_TAG) \
	docker-compose up -d
	-sleep 5
	@echo "=> container $(ROOT_DOCKER_CONTAINER_NAME) now status"
	docker inspect --format='{{ .State.Status}}' $(ROOT_DOCKER_CONTAINER_NAME)
	@echo "=> see log with: docker logs $(ROOT_DOCKER_CONTAINER_NAME) -f"

localIPDarwin:
	@echo "=> now run as docker with darwin"
	@echo "local ip address is: $(ROOT_LOCAL_IP_V4_DARWIN)"

dockerRunDarwin: localIPDarwin
	-docker image inspect --format='{{ .Created}}' $(ROOT_DOCKER_IMAGE_NAME):$(ROOT_DOCKER_IMAGE_TAG)
	ENV_CRON_HOST=$(ROOT_LOCAL_IP_V4_DARWIN) \
	ENV_CRON_PORT=$(ROOT_DOCKER_CONTAINER_PORT) \
	ROOT_NAME=$(ROOT_DOCKER_IMAGE_NAME) \
	DIST_TAG=$(ROOT_DOCKER_IMAGE_TAG) \
	docker-compose up -d
	-sleep 5
	@echo "=> container $(ROOT_DOCKER_CONTAINER_NAME) now status"
	docker inspect --format='{{ .State.Status}}' $(ROOT_DOCKER_CONTAINER_NAME)
	@echo "=> see log with: docker logs $(ROOT_DOCKER_CONTAINER_NAME) -f"

dockerRestartDarwin: localIPDarwin
	docker inspect --format='{{ .State.Status}}' $(ROOT_NAME)
	ENV_CRON_HOST=$(ROOT_LOCAL_IP_V4_DARWIN) \
	ENV_CRON_PORT=$(ROOT_DOCKER_CONTAINER_PORT) \
	ROOT_NAME=$(ROOT_DOCKER_IMAGE_NAME) \
	DIST_TAG=$(ROOT_DOCKER_IMAGE_TAG) \
	docker-compose restart
	-sleep 5
	@echo "=> container $(ROOT_DOCKER_CONTAINER_NAME) now status"
	docker inspect --format='{{ .State.Status}}' $(ROOT_DOCKER_CONTAINER_NAME)
	@echo "=> see log with: docker logs $(ROOT_DOCKER_CONTAINER_NAME) -f"

dockerStop:
	ROOT_NAME=$(ROOT_DOCKER_IMAGE_NAME) \
	DIST_TAG=$(ROOT_DOCKER_IMAGE_TAG) \
	ENV_CRON_PORT=$(ROOT_DOCKER_CONTAINER_PORT) \
	docker-compose stop

dockerContainRemove:
	ROOT_NAME=$(ROOT_DOCKER_IMAGE_NAME) \
	DIST_TAG=$(ROOT_DOCKER_IMAGE_TAG) \
	ENV_CRON_PORT=$(ROOT_DOCKER_CONTAINER_PORT) \
	docker-compose rm -f

dockerBuildRemove: dockerStop dockerContainRemove dockerLocalImageRemove
	@echo "=> after build remove, please check docker contain or images status to confirm."

dockerBuild: dockerBuildRemove dockerLocalFileRest dockerLocalImageRebuild
	@echo "=> after build please check docker contain or images status to confirm."

dockerBuildRun: clean dockerBuild dockerRun
	@echo ""

dockerLessBuild: dockerBuildRemove dockerLocalFileLess dockerLocalImageRebuild
	@echo "=> after less build please check docker contain or images status to confirm."

dockerLessBuildRun: clean dockerLessBuild dockerRun
	@echo "=> after less build run please check docker contain or images status to confirm."

dockerLessDist: clean dockerLocalFileLess dockerLocalImageRebuild dockerLocalFileRest checkReleaseOSDistPath
	@echo "=> check build image [docker image $(ROOT_DOCKER_IMAGE_NAME):$(ROOT_DOCKER_IMAGE_TAG) ]"
	@echo "-> docker image has binary only use docker-compose and config file to use"
	mkdir $(ROOT_REPO_OS_DIST_PATH)/conf/
	cp ./conf/release/config.yaml $(ROOT_REPO_OS_DIST_PATH)/conf/
	cp ./conf/release/docker-compose.yml $(ROOT_REPO_OS_DIST_PATH)
	@echo "=> pkg at: $(ROOT_REPO_OS_DIST_PATH)"

dockerPrune: dockerStop
	ROOT_NAME=$(ROOT_DOCKER_IMAGE_NAME) \
	DIST_TAG=$(ROOT_DOCKER_IMAGE_TAG) \
	ENV_CRON_PORT=$(ROOT_DOCKER_CONTAINER_PORT) \
	docker-compose rm -f $(ROOT_DOCKER_IMAGE_NAME)
	-docker rmi -f $(ROOT_DOCKER_IMAGE_NAME):$(ROOT_DOCKER_IMAGE_TAG)
	docker network prune
	docker volume prune

helpDockerRun:
	@echo "Help: MakeDockerRun.mk"
	@echo "you can use dockerLocalFileLess build less raw image"
	@echo "~> make dockerLocalFileLess to init Docker image file need"
	@echo "~> make dockerLocalFileRest to reset Docker image file"
	@echo "Before run this project in docker must or can not find docker image"
	@echo "~> make dockerLocalImageRebuild to rebuild Docker image"
	@echo "After build Docker image build success"
	@echo ""
	@echo "~> make dockerBuildRun  - clean full build and build run in docker"
	@echo "~> make dockerLessDist  - clean full build and build docker image wait docker-compose"
	@echo ""
	@echo "~> make dockerRun       - run docker-compose server as $(ROOT_DOCKER_IMAGE_NAME):$(ENV_DIST_VERSION) \
	container-name at $(ROOT_DOCKER_CONTAINER_NAME)"
	@echo "~> make dockerRunLinux  - run docker-compose server as $(ROOT_DOCKER_IMAGE_NAME):$(ENV_DIST_VERSION) \
	container-name at $(ROOT_DOCKER_CONTAINER_NAME) in dockerRunLinux"
	@echo "~> make dockerRunDarwin - run docker-compose server as $(ROOT_DOCKER_IMAGE_NAME):$(ENV_DIST_VERSION) \
	container-name at $(ROOT_DOCKER_CONTAINER_NAME) in macOS"
	@echo "~> make dockerStop      - stop docker-compose container-name at $(ROOT_DOCKER_CONTAINER_NAME)"
	@echo "~> make dockerPrune     - stop docker-compose container-name at $(ROOT_DOCKER_CONTAINER_NAME) and try to remove"
	@echo ""