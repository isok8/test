# 构建可执行二进制文件
# 指定构建的基础镜像
FROM golang:alpine AS builder
# 修改源
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
# 安装相关环境依赖
RUN apk update && apk add --no-cache git bash wget curl unzip
# 运行工作目录
WORKDIR /go/src/xray.com/core
# 克隆源码运行安装
RUN wget https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip -O /tmp/latest-Xray.zip

# 构建基础镜像
# 指定创建的基础镜像
FROM alpine:latest
# 作者描述信息
MAINTAINER jiaosir
# 语言设置
ENV LANG zh_CN.UTF-8
# 时区设置
ENV TZ=Asia/Shanghai
# 修改源
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
# 更新源
RUN apk upgrade
# 同步时间
RUN apk add -U tzdata \
&& ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \
&& echo ${TZ} > /etc/timezone

# 拷贝xray二进制文件至临时目录
COPY --from=builder /tmp/latest-Xray.zip /tmp

# 授予文件权限
RUN set -ex && \
    apk --no-cache add ca-certificates && \
    mkdir -p /usr/bin/xray /etc/xray && \
    unzip -o -d /usr/bin/xray /tmp/latest-Xray.zip && \
    rm -rf /tmp/latest-Xray.zip /usr/bin/xray/*.sig /usr/bin/xray/doc /usr/bin/xray/*.json /usr/bin/xray/*.dat /usr/bin/xray/sys* && \
    chmod +x /usr/bin/xray/xray




# 设置环境变量
ENV PATH /usr/bin/xray:$PATH

# 拷贝配置文件
COPY config.json /etc/xray/config.json

# 运行xray
CMD ["xray", "-config=/etc/xray/config.json"]
