# syntax=docker/dockerfile:1.2-labs
# 使用 BuildKit 进行构建

FROM ubuntu:22.04 AS base

ARG DEBIAN_FRONTEND=noninteractive
ARG EMAIL
ARG PASSWORD

# 设置环境变量
ENV EMAIL=${EMAIL}
ENV PASSWORD=${PASSWORD}

# 更新包列表并安装依赖项
RUN apt-get update && apt-get install -y curl gzip git

# 创建工作目录
WORKDIR /opt/

# 下载并解压 Blockmesh CLI
FROM base AS build
RUN curl -sLO https://github.com/block-mesh/block-mesh-monorepo/releases/latest/download/blockmesh-cli-x86_64-unknown-linux-gnu.tar.gz \
    && tar -xvf blockmesh-cli-x86_64-unknown-linux-gnu.tar.gz \
    && mv target/x86_64-unknown-linux-gnu/release/blockmesh-cli /usr/local/bin/blockmesh-cli \
    && chmod +x /usr/local/bin/blockmesh-cli

# 创建启动脚本
RUN echo '#!/bin/bash\n\
echo "Starting Blockmesh CLI..."\n\
exec /usr/local/bin/blockmesh-cli --email "$EMAIL" --password "$PASSWORD"\n' > /usr/local/bin/entrypoint.sh \
    && chmod +x /usr/local/bin/entrypoint.sh

# 设置入口点
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
