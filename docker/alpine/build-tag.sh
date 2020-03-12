#!/usr/bin/env bash

build_version=v1.11.1

build_catch_top_path=build
build_os=alpine
build_os_version=3.10
build_go_image=golang:1.13-alpine
build_docker_image_tag_mk_out=cron
go_proxy_url=https://goproxy.cn/

build_root_path=../../
build_out_path=../../${build_catch_top_path}/${build_os}
build_source_root=../../${build_catch_top_path}/${build_os}/${build_docker_image_tag_mk_out}


docker_temp_contain=temp-go-cron
docker_temp_name=temp-go/go-cron
docker_temp_tag=${build_version}
docker_cp_from=/cron
docker_cp_to=../../${build_catch_top_path}/${build_os}


run_path=$(pwd)
shell_run_name=$(basename $0)
shell_run_path=$(cd `dirname $0`; pwd)

pV(){
    echo -e "\033[;36m$1\033[0m"
}
pI(){
    echo -e "\033[;32m$1\033[0m"
}
pD(){
    echo -e "\033[;34m$1\033[0m"
}
pW(){
    echo -e "\033[;33m$1\033[0m"
}
pE(){
    echo -e "\033[;31m$1\033[0m"
}

checkFuncBack(){
    if [[ $? -ne 0 ]]; then
        echo -e "\033[;31mRun [ $1 ] error exit code 1\033[0m"
        exit 1
    fi
}

checkBinary(){
    binary_checker=`which $1`
    checkFuncBack "which $1"
    if [[ ! -n "${binary_checker}" ]]; then
        echo -e "\033[;31mCheck binary [ $1 ] error exit\033[0m"
        exit 1
        #  else
        #    echo -e "\033[;32mCli [ $1 ] event check success\033[0m\n-> \033[;34m$1 at Path: ${evn_checker}\033[0m"
    fi
}

check_root(){
    if [[ ${EUID} != 0 ]]; then
        echo "no not root user"
    fi
}

dockerIsHasContainByName(){
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

dockerStopContainWhenRunning(){
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

dockerRemoveContainSafe(){
    if [[ ! -n $1 ]]; then
        pW "Want remove contain is empty"
    else
        has_contain=$(dockerIsHasContainByName $1)
        if [ ${has_contain} -eq 0 ];then
            dockerStopContainWhenRunning $1
            c_status=$(docker inspect --format='{{ .State.Status}}' $1)
            if [ "exited" == ${c_status} ]; then
                pD "-> docker rm contain [ $1 ]"
                docker rm $1
                checkFuncBack "docker rm $1"
            fi
            if [ "created" ==  ${c_status} ]; then
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



# replace build Dockerfile
echo -e "# This dockerfile uses extends image https://hub.docker.com/_${build_os}
# VERSION ${build_version}
# Author: ${USER}
# dockerfile offical document https://docs.docker.com/engine/reference/builder/
FROM ${build_go_image} as builder
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
RUN apk --no-cache add make git gcc libtool musl-dev
WORKDIR /
COPY . /
RUN make dockerLocalImageBuild

FROM alpine:${build_os_version}
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
RUN apk --no-cache add ca-certificates && \\
    rm -rf /var/cache/apk/* /tmp/*
COPY --from=builder /${build_docker_image_tag_mk_out} /usr/src/myapp/
COPY --from=builder /conf/release/config.yaml /usr/src/myapp/conf/
ENTRYPOINT [\"tail\",  \"-f\", \"/etc/alpine-release\"]
" > ${build_root_path}Dockerfile

exit 0

dockerRemoveContainSafe ${docker_temp_contain}

# run image to coyp build used file
docker create --name ${docker_temp_contain} ${docker_temp_name}:${docker_temp_tag}
checkFuncBack "docker create --name ${docker_temp_contain} ${docker_temp_name}:${docker_temp_tag}"
docker cp ${docker_temp_contain}:${docker_cp_from} ${docker_cp_to}
checkFuncBack "docker cp ${docker_temp_contain}:${docker_cp_from} ${docker_cp_to}"

# clean local container and images abs

# dockerRemoveContainSafe ${docker_temp_contain}
# docker rmi -f ${docker_temp_name}:${docker_temp_tag}
# (while :; do echo 'y'; sleep 3; done) | docker container prune
# (while :; do echo 'y'; sleep 3; done) | docker image prune

# clean local container and images
read -t 7 -p "Are you sure to remove container? [y/n] " remove_container_input
case $remove_container_input in
    [yY]*)
        dockerRemoveContainSafe ${docker_temp_contain}
        (while :; do echo 'y'; sleep 3; done) | docker container prune
        echo ""
        echo "-> just remove all exit container!"
    ;;
    [nN]*)
        pI "-> not remove container you can try as"
        echo "docker rm ${docker_temp_contain}"
        pI "to remove contain, but not full of contain"
        pI "if want remove full just use"
        echo "(while :; do echo 'y'; sleep 3; done) | docker container prune"
        echo ""
    ;;
    *)
        echo "-> out of time or unknow command remove container"
        pI "remove container you can try as"
        echo "docker rm ${docker_temp_contain}"
        pI "to remove contain, but not full of contain"
        pI "if want remove full just use"
        echo "(while :; do echo 'y'; sleep 3; done) | docker container prune"
        echo ""
    ;;
esac

read -t 7 -p "Are you sure to remove image prune? [y/n] " remove_image_input
case $remove_image_input in
    [yY]*)
        docker rmi -f ${docker_temp_name}:${docker_temp_tag}
        (while :; do echo 'y'; sleep 3; done) | docker image prune
        echo ""
        echo "-> just remove all prune image!"
    ;;
    [nN]*)
        pI "-> now not remove image you can try as"
        echo "docker rmi -f ${docker_temp_name}:${docker_temp_tag}"
        echo ""
        pI "if want remove full just use"
        echo "(while :; do echo 'y'; sleep 3; done) | docker image prune"
        echo ""
    ;;
    *)
        echo "-> out of time or unknow command remove image prune"
        pI "remove image you can try as"
        echo "docker rmi -f ${docker_temp_name}:${docker_temp_tag}"
        echo ""
        pI "if want remove full just use"
        echo "(while :; do echo 'y'; sleep 3; done) | docker image prune"
        echo ""
    ;;
esac
echo "=> must check out build images !"

exit 0

# let Dockerfile be default
echo -e "# This dockerfile uses extends image https://hub.docker.com/_/golang
# VERSION ${build_version}
# Author: ${USER}
# dockerfile offical document https://docs.docker.com/engine/reference/builder/
# https://hub.docker.com/_/golang?tab=description
FROM ${build_go_image}

COPY $PWD /usr/src/myapp
WORKDIR /usr/src/myapp
RUN make initDockerDevImages

#ENTRYPOINT [ \"go\", \"env\" ]
" > Dockerfile
