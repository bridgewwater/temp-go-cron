.PHONY: test check clean build dist all

TOP_DIR := $(shell pwd)

# ifeq ($(FILE), $(wildcard $(FILE)))
# 	@ echo target file not found
# endif

# need open proxy 1 is need 0 is default
ENV_NEED_PROXY=1

ENV_DIST_VERSION := v1.0.0
# linux windows darwin  list as: go tool dist list
ENV_DIST_OS := linux
ENV_DIST_ARCH := amd64

ENV_DIST_OS_DOCKER ?= linux
ENV_DIST_ARCH_DOCKER ?= amd64

ROOT_NAME ?= temp-go-cron

# ignore used not matching mode
ROOT_TEST_INVERT_MATCH ?= "vendor|go_fatal_error|robotn|shirou|go_robot"
# set ignore of test case like grep -v -E "vendor|go_fatal_error" to ignore vendor and go_fatal_error package
ROOT_TEST_LIST := $$(go list ./... | grep -v -E $(ROOT_TEST_INVERT_MATCH))
# test max time
ROOT_TEST_MAX_TIME := 1m

ROOT_BUILD_PATH ?= ./build
ROOT_DIST ?= ./dist
ROOT_REPO ?= ./dist
ROOT_LOG_PATH ?= ./log
ROOT_SWAGGER_PATH ?= ./docs

ROOT_TEST_BUILD_PATH ?= $(ROOT_BUILD_PATH)/test/$(ENV_DIST_VERSION)
ROOT_TEST_DIST_PATH ?= $(ROOT_DIST)/test/$(ENV_DIST_VERSION)
ROOT_TEST_OS_DIST_PATH ?= $(ROOT_DIST)/$(ENV_DIST_OS)/test/$(ENV_DIST_VERSION)
ROOT_REPO_DIST_PATH ?= $(ROOT_REPO)/$(ENV_DIST_VERSION)
ROOT_REPO_OS_DIST_PATH ?= $(ROOT_REPO)/$(ENV_DIST_OS)/release/$(ENV_DIST_VERSION)

ROOT_LOCAL_IP_V4_LINUX = $$(ifconfig enp8s0 | grep inet | grep -v inet6 | cut -d ':' -f2 | cut -d ' ' -f1)
ROOT_LOCAL_IP_V4_DARWIN = $$(ifconfig en0 | grep inet | grep -v inet6 | cut -d ' ' -f2)

SERVER_TEST_SSH_ALIASE = aliyun-ecs
SERVER_TEST_FOLDER = /home/work/Document/
SERVER_REPO_SSH_ALIASE = temp-gin-web
SERVER_REPO_FOLDER = /home/ubuntu/$(ROOT_NAME)

# can use as https://goproxy.io/ https://gocenter.io https://mirrors.aliyun.com/goproxy/
ENV_GO_PROXY ?= https://goproxy.cn/

# include MakeDockerRun.mk for docker run
include MakeGoMod.mk
include MakeDockerRun.mk

checkEnvGo:
ifndef GOPATH
	@echo Environment variable GOPATH is not set
	exit 1
endif

# check must run environment
init:
	@echo "~> start init this project"
	@echo "-> check version"
	go version
	@echo "-> check env golang"
	go env
	@echo "~> you can use [ make help ] see more task"

cleanBuild:
	@if [ -d ${ROOT_BUILD_PATH} ]; \
	then rm -rf ${ROOT_BUILD_PATH} && echo "~> cleaned ${ROOT_BUILD_PATH}"; \
	else echo "~> has cleaned ${ROOT_BUILD_PATH}"; \
	fi

cleanDist:
	@if [ -d ${ROOT_DIST} ]; \
	then rm -rf ${ROOT_DIST} && echo "~> cleaned ${ROOT_DIST}"; \
	else echo "~> has cleaned ${ROOT_DIST}"; \
	fi

cleanLog:
	@if [ -d ${ROOT_LOG_PATH} ]; \
	then rm -rf ${ROOT_LOG_PATH} && echo "~> cleaned ${ROOT_LOG_PATH}"; \
	else echo "~> has cleaned ${ROOT_LOG_PATH}"; \
	fi

clean: cleanBuild cleanLog
	@echo "~> clean finish"

checkTestBuildPath:
	@if [ ! -d ${ROOT_TEST_BUILD_PATH} ]; \
	then mkdir -p ${ROOT_TEST_BUILD_PATH} && echo "~> mkdir ${ROOT_TEST_BUILD_PATH}"; \
	fi

checkTestDistPath:
	@if [ ! -d ${ROOT_TEST_DIST_PATH} ]; \
	then mkdir -p ${ROOT_TEST_DIST_PATH} && echo "~> mkdir ${ROOT_TEST_DIST_PATH}"; \
	fi

checkTestOSDistPath:
	@if [ ! -d ${ROOT_TEST_OS_DIST_PATH} ]; \
	then mkdir -p ${ROOT_TEST_OS_DIST_PATH} && echo "~> mkdir ${ROOT_TEST_OS_DIST_PATH}"; \
	fi

checkReleaseDistPath:
	@if [ ! -d ${ROOT_REPO_DIST_PATH} ]; \
	then mkdir -p ${ROOT_REPO_DIST_PATH} && echo "~> mkdir ${ROOT_REPO_DIST_PATH}"; \
	fi

checkReleaseOSDistPath:
	@if [ ! -d ${ROOT_REPO_OS_DIST_PATH} ]; \
	then mkdir -p ${ROOT_REPO_OS_DIST_PATH} && echo "~> mkdir ${ROOT_REPO_OS_DIST_PATH}"; \
	fi

buildMain: dep
	@echo "-> start build local OS"
	@go build -o build/main main.go

buildARCH: dep
	@echo "-> start build OS:$(ENV_DIST_OS) ARCH:$(ENV_DIST_ARCH)"
	@GOOS=$(ENV_DIST_OS) GOARCH=$(ENV_DIST_ARCH) go build -tags netgo -o build/main main.go

buildDocker: dep cleanBuild
	@echo "-> start build OS:$(ENV_DIST_OS_DOCKER) ARCH:$(ENV_DIST_ARCH_DOCKER)"
	@GOOS=$(ENV_DIST_OS_DOCKER) GOARCH=$(ENV_DIST_ARCH_DOCKER) go build -o build/main main.go

test:
	@echo "=> run test start"
	#=> go test -test.v $(ROOT_TEST_LIST)
	@go test -test.v $(ROOT_TEST_LIST)
testBenchmem:
	@echo "=> run test benchmem start"
	@go test -test.benchmem

dev: buildMain
	-ENV_CRON_AUTO_HOST=true ./build/main -c ./conf/config.yaml

runTest: buildMain
	-ENV_CRON_AUTO_HOST=true ./build/main -c ./conf/test/config.yaml

distTest: buildMain checkTestDistPath
	mv ./build/main $(ROOT_TEST_DIST_PATH)
	mkdir $(ROOT_TEST_DIST_PATH)/conf/
	cp ./conf/test/config.yaml $(ROOT_TEST_DIST_PATH)/conf/
	@echo "=> pkg at: $(ROOT_TEST_DIST_PATH)"

tarDistTest: distTest
	cd $(ROOT_DIST)/test && tar zcvf $(ROOT_NAME)-test-$(ENV_DIST_VERSION).tar.gz $(ENV_DIST_VERSION)

distTestOS: buildARCH checkTestOSDistPath
	@echo "=> Test at: $(ENV_DIST_OS) ARCH as: $(ENV_DIST_ARCH)"
	mv ./build/main $(ROOT_TEST_OS_DIST_PATH)
	mkdir $(ROOT_TEST_OS_DIST_PATH)/conf/
	cp ./conf/test/config.yaml $(ROOT_TEST_OS_DIST_PATH)/conf/
	@echo "=> pkg at: $(ROOT_TEST_OS_DIST_PATH)"

distRelease: buildMain checkReleaseDistPath
	mv ./build/main $(ROOT_REPO_DIST_PATH)
	mkdir $(ROOT_REPO_DIST_PATH)/conf/
	cp ./conf/release/config.yaml $(ROOT_REPO_DIST_PATH)/conf/
	@echo "=> pkg at: $(ROOT_REPO_DIST_PATH)"

distReleaseOS: buildARCH checkReleaseOSDistPath
	@echo "=> Release at: $(ENV_DIST_OS) ARCH as: $(ENV_DIST_ARCH)"
	mv ./build/main $(ROOT_REPO_OS_DIST_PATH)
	mkdir $(ROOT_REPO_OS_DIST_PATH)/conf/
	cp ./conf/release/config.yaml $(ROOT_REPO_OS_DIST_PATH)/conf/
	@echo "=> pkg at: $(ROOT_REPO_OS_DIST_PATH)"

tarDistReleaseOS: distReleaseOS
	@echo "=> start tar release as os $(ENV_DIST_OS) $(ENV_DIST_ARCH)"
	tar zcvf $(ROOT_DIST)/$(ENV_DIST_OS)/release/$(ROOT_NAME)-$(ENV_DIST_OS)-$(ENV_DIST_ARCH)-$(ENV_DIST_VERSION).tar.gz $(ROOT_REPO_OS_DIST_PATH)

scpTestOS:
	@echo "=> must check below config of set for testOSScp"
	#scp -r $(ROOT_TEST_OS_DIST_PATH) $(SERVER_TEST_SSH_ALIASE):$(SERVER_TEST_FOLDER)

scpDockerComposeTest:
	# scp ./conf/test/docker-compose.yml $(SERVER_TEST_SSH_ALIASE):$(SERVER_TEST_FOLDER)
	@echo "=> finish update docker compose at test"

helpProjectRoot:
	@echo "Help: Project root Makefile"
	@echo "-- distTestOS or distReleaseOS will out abi as: $(ENV_DIST_OS) $(ENV_DIST_ARCH) --"
	@echo "~> make distTest         - build dist at $(ROOT_TEST_DIST_PATH) in local OS"
	@echo "~> make tarDistTest      - build dist at $(ROOT_TEST_OS_DIST_PATH) and tar"
	@echo "~> make distTestOS       - build dist at $(ROOT_TEST_OS_DIST_PATH) as: $(ENV_DIST_OS) $(ENV_DIST_ARCH)"
	@echo "~> make distRelease      - build dist at $(ROOT_REPO_DIST_PATH) in local OS"
	@echo "~> make distReleaseOS    - build dist at $(ROOT_REPO_OS_DIST_PATH) as: $(ENV_DIST_OS) $(ENV_DIST_ARCH)"
	@echo "~> make tarDistReleaseOS - build dist at $(ROOT_REPO_OS_DIST_PATH) as: $(ENV_DIST_OS) $(ENV_DIST_ARCH) and tar"
	@echo ""
	@echo "-- now build name: $(ROOT_NAME) version: $(ENV_DIST_VERSION)"
	@echo "~> make init         - check base env of this project"
	@echo "~> make clean        - remove binary file and log files"
	@echo "~> make test         - run test case all"
	@echo "~> make testBenchmem - run go test benchmem case all"
	@echo "~> make runTest      - run server use conf/test/config.yaml"
	@echo "~> make dev          - run server use conf/config.yaml"

help: helpGoMod helpDockerRun helpProjectRoot
	@echo ""
	@echo "-- more info see Makefile include: MakeGoMod.mk MakeDockerRun.mk --"
