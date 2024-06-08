# Dockerfile
FROM dreamacro/clash-premium
RUN set -e \
    ## && sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories \
    && apk add --no-cache iptables inotify-tools tini \
    && wget https://github.com/haishanh/yacd/releases/download/v0.3.8/yacd.tar.xz \
    && tar xf yacd.tar.xz \
    && mv public ui

# 设置工作目录为 /app
WORKDIR /app
COPY scripts /app/scripts
RUN chmod +x /app/scripts/entrypoint.sh
RUN chmod +x /app/scripts/iptables-down.sh /app/scripts/iptables.sh
RUN mv /app/scripts/entrypoint.sh /
RUN mv /app/scripts/iptables-down.sh /
RUN mv /app/scripts/iptables.sh /

ENTRYPOINT ["tini","-g", "--", "/entrypoint.sh"]
