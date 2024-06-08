#!/bin/sh
# scripts/entrypoint.sh

set -e

CONFIG="/root/.config/clash"

mkdir -p "$CONFIG"

# 如果文件不存在，就把镜像内置的文件移动过去
mvFile() {
    if [ ! -f "$CONFIG/$1" ]; then
        mv "/$1" "$CONFIG/$1"
    fi
}
mvFile iptables.sh
mvFile iptables-down.sh

sh "$CONFIG/iptables.sh" # 将入口TCP请求重定向到 Clash

stopClash() {
    # 给 Clash 进程发 SIGTERM
    ps -ef|grep /clash|head -1|awk '{print $1}'|xargs kill 2>/dev/null
}

# 容器退出时的清理工作
clear() {
    sh "$CONFIG/iptables-down.sh"
    kill -9 -1 2>/dev/null || exit 0
}

# 捕获SIG信号，回调清理
trap clear SIGTERM SIGINT SIGQUIT SIGHUP ERR

startClash() {
    trap clear ERR # clash启动错误时退出容器
    /clash -ext-ui /ui
}

startClash &

sleep 5 # 等待配置文件被clash创建

echo '配置文件已建立监听'

# 监听配置文件修改，重启clash
while inotifywait -q -e close_write "$CONFIG/config.yaml";
do
echo "检测到配置文件变更，Clash重启中。。。"
stopClash
startClash &
done
