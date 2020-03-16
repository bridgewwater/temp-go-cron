# This dockerfile uses extends image https://hub.docker.com/_alpine
# VERSION v1.11.1
# Author: sinlov
# dockerfile offical document https://docs.docker.com/engine/reference/builder/
FROM golang:1.13.3-alpine as builder
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
RUN apk --no-cache add make git gcc libtool musl-dev
COPY $PWD /usr/src/myapp
WORKDIR /usr/src/myapp
RUN make initDockerImagesMod dockerLocalImageBuildFile

FROM alpine:3.10
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
RUN apk --no-cache add ca-certificates && \
    rm -rf /var/cache/apk/* /tmp/*
COPY --from=builder /usr/src/myapp/go-cron-bin /usr/src/myapp/
COPY --from=builder /usr/src/myapp/conf/release/config.yaml /usr/src/myapp/conf/

WORKDIR /usr/src/myapp
CMD ["tail",  "-f", "/etc/alpine-release"]

