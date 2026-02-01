# ============================================================
# OpenClaw 汉化发行版 - Docker 镜像
# 武汉晴辰天下网络科技有限公司 | https://qingchencloud.com/
# ============================================================
#
# 注意：此 Dockerfile 假设代码已在 GitHub Actions 中构建完成
# 构建上下文应包含 dist/ 目录和 node_modules/
#
# ============================================================

FROM node:22-slim
LABEL org.opencontainers.image.source="https://github.com/1186258278/OpenClawChineseTranslation"
LABEL org.opencontainers.image.description="OpenClaw 汉化发行版 - 开源个人 AI 助手中文版"
LABEL org.opencontainers.image.licenses="MIT"
LABEL maintainer="武汉晴辰天下网络科技有限公司 <contact@qingchencloud.com>"
# 安装运行时依赖 + 编译工具链 (Python, Make, G++)
# 编译工具用于在 ARM64 下构建原生模块
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    chromium \
    python3 \
    make \
    g++ \
    build-essential \
    && rm -rf /var/lib/apt/lists/*
# 设置 Chromium 环境变量
ENV CHROME_BIN=/usr/bin/chromium
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium
# 设置工作目录
WORKDIR /app
# 复制所有代码
# 注意：workflow 必须在 COPY 前删掉宿主机的 node_modules，
# 否则会将 x86 的二进制文件带入 arm64 镜像
COPY . .
# 重新安装依赖
# 我们删除了外部的 node_modules，所以这里必须执行 install
# --omit=dev 减少镜像体积，只安装运行时需要的包
RUN npm install --omit=dev
# 全局安装
RUN npm install -g .
# 清理编译工具以减小镜像体积 (可选，为了调试方便也可保留)
# RUN apt-get remove -y python3 make g++ build-essential && apt-get autoremove -y
# 创建配置目录
RUN mkdir -p /root/.openclaw
# 暴露端口
EXPOSE 18789
# 数据持久化目录
VOLUME ["/root/.openclaw"]
# 默认启动命令
CMD ["openclaw"]
