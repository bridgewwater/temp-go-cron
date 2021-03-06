#!/usr/bin/env bash

build_version=v1.11.1
build_docker_image_name=golang
build_docker_tag=1.13.8-alpine

build_docker_set=${build_docker_image_name}:${build_docker_tag}

build_root_path=../../
build_root_name=temp-go-cron

build_need_proxy=0
go_proxy_url=https://goproxy.cn/
alpinelinux_proxy=mirrors.aliyun.com
docker_none_mark=none

run_path=$(pwd)
shell_run_name=$(basename $0)
shell_run_path=$(
  cd $(dirname $0)
  pwd
)

pV() {
  echo -e "\033[;36m$1\033[0m"
}
pI() {
  echo -e "\033[;32m$1\033[0m"
}
pD() {
  echo -e "\033[;34m$1\033[0m"
}
pW() {
  echo -e "\033[;33m$1\033[0m"
}
pE() {
  echo -e "\033[;31m$1\033[0m"
}

checkFuncBack() {
  if [[ $? -ne 0 ]]; then
    echo -e "\033[;31mRun [ $1 ] error exit code 1\033[0m"
    exit 1
  fi
}

checkBinary() {
  binary_checker=$(which $1)
  checkFuncBack "which $1"
  if [[ ! -n "${binary_checker}" ]]; then
    echo -e "\033[;31mCheck binary [ $1 ] error exit\033[0m"
    exit 1
    #  else
    #    echo -e "\033[;32mCli [ $1 ] event check success\033[0m\n-> \033[;34m$1 at Path: ${evn_checker}\033[0m"
  fi
}

check_root() {
  if [[ ${EUID} != 0 ]]; then
    echo "no not root user"
  fi
}

dockerIsHasContainByName() {
  if [[ ! -n $1 ]]; then
    pW "Want find contain is empty"
    echo "-1"
  else
    c_status=$(docker inspect $1)
    if [ ! $? -eq 0 ]; then
      echo "1"
    else
      echo "0"
    fi
  fi
}

dockerStopContainWhenRunning() {
  if [[ ! -n $1 ]]; then
    pW "Want stop contain is empty"
  else
    c_status=$(docker inspect --format='{{ .State.Status}}' $1)
    if [ "running" == ${c_status} ]; then
      pD "-> docker stop contain [ $1 ]"
      docker stop $1
      checkFuncBack "docker stop $1"
    fi
  fi
}

dockerRemoveContainSafe() {
  if [[ ! -n $1 ]]; then
    pW "Want remove contain is empty"
  else
    has_contain=$(dockerIsHasContainByName $1)
    if [ ${has_contain} -eq 0 ]; then
      dockerStopContainWhenRunning $1
      c_status=$(docker inspect --format='{{ .State.Status}}' $1)
      if [ "exited" == ${c_status} ]; then
        pD "-> docker rm contain [ $1 ]"
        docker rm $1
        checkFuncBack "docker rm $1"
      fi
      if [ "created" == ${c_status} ]; then
        pD "-> docker rm contain [ $1 ]"
        docker rm $1
        checkFuncBack "docker rm $1"
      fi
    else
      pE "dockerRemoveContainSafe Not found contain [ $1 ]"
    fi
  fi
}

# checkenv
checkBinary docker

while getopts "hpb:n:i:" arg; do #after param has ":" need option
  case $arg in
  p) # -p open proxy of build
    build_need_proxy=1
    ;;
  b) # -b [v1.0.0] build version of contains
    build_version=${OPTARG}
    ;;
  n) # -n [temp-go-cron] name of build
    build_root_name=${OPTARG}
    ;;
  i) # -i [1.13.8-alpine] build docker image tag of golang https://hub.docker.com/_/golang
    build_docker_tag=${OPTARG}
    build_docker_set=${build_docker_image_name}:${build_docker_tag}
    ;;
  h)
    echo -e "this script to mark docker build file
    use as ${shell_run_name} -p
ars:
  -p open proxy of build
  -b [v1.0.0] build version of contains
  -n [temp-go-cron] name of build
  -i [1.13.8-alpine] build docker image tag of golang https://hub.docker.com/_/golang
"
    ;;
  ?) # other param?
    echo "unkonw argument, plase use -h to show help"
    exit 1
    ;;
  esac
done

# let Dockerfile be default
if [[ ${build_need_proxy} -eq 1 ]]; then
  echo -e "# This dockerfile uses extends image https://hub.docker.com/_/golang
# VERSION ${build_version}
# Author: ${USER}
# dockerfile offical document https://docs.docker.com/engine/reference/builder/
# https://hub.docker.com/_/golang?tab=description
FROM ${build_docker_set}

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
RUN apk --no-cache add make git gcc libtool musl-dev

COPY \$PWD /usr/src/myapp
WORKDIR /usr/src/myapp
RUN make initDockerImagesMod

CMD [\"tail\",  \"-f\", \"/etc/alpine-release\"]
#ENTRYPOINT [ \"go\", \"env\" ]
" >${build_root_path}Dockerfile
else
  echo -e "# This dockerfile uses extends image https://hub.docker.com/_/golang
# VERSION ${build_version}
# Author: ${USER}
# dockerfile offical document https://docs.docker.com/engine/reference/builder/
# https://hub.docker.com/_/golang?tab=description
FROM ${build_docker_set}

RUN apk --no-cache add make git gcc libtool musl-dev

COPY \$PWD /usr/src/myapp
WORKDIR /usr/src/myapp
RUN make initDockerImagesMod

CMD [\"tail\",  \"-f\", \"/etc/alpine-release\"]
#ENTRYPOINT [ \"go\", \"env\" ]
" >${build_root_path}Dockerfile
fi

echo -e "# copy right
# Licenses http://www.apache.org/licenses/LICENSE-2.0
# more info see https://docs.docker.com/compose/compose-file/ or https://docker.github.io/compose/compose-file/
version: '3.7'

networks:
  default:
#volumes:
#  web-data:
services:
  ${build_root_name}:
    container_name: \"\${ROOT_NAME}\"
    image: '\${ROOT_NAME}:\${DIST_TAG}' # see local docker file
    ports:
      - \"39000:\${ENV_CRON_PORT}\"
    volumes:
      - \"\$PWD:/usr/src/myapp\"
    environment:
      - ENV_CRON_HTTPS_ENABLE=false
      - ENV_CRON_AUTO_HOST=false
      - ENV_CRON_HOST=\${ENV_CRON_HOST}:\${ENV_CRON_PORT}
#      - ENV_CRON_HOST=0.0.0.0:39000
    working_dir: \"/usr/src/myapp\"
    command:
      - make
      - dev
" >${build_root_path}docker-compose.yml

docker images | grep ${docker_none_mark} | awk '{print $3}' | xargs docker rmi

exit 0
