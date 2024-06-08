#!/bin/sh
# scripts/iptables.sh


set -e
iptables --policy FORWARD ACCEPT
iptables -t nat -N CLASH || echo 'CLASH链已存在--即将清空' # 给nat表新增一个名为 CLASH 的链
iptables -t nat -F CLASH # 清空CLASH链，保证二次执行没问题
iptables -t nat -A CLASH -d 10.0.0.0/8 -j RETURN
iptables -t nat -A CLASH -d 127.0.0.0/8 -j RETURN
iptables -t nat -A CLASH -d 169.254.0.0/16 -j RETURN
iptables -t nat -A CLASH -d 172.16.0.0/12 -j RETURN
iptables -t nat -A CLASH -d 192.168.0.0/16 -j RETURN
iptables -t nat -A CLASH -d 224.0.0.0/4 -j RETURN
iptables -t nat -A CLASH -d 240.0.0.0/4 -j RETURN
iptables -t nat -A CLASH -i enp3s0 -p tcp -j REDIRECT --to-ports 7892 # 到这一步还没return就全走代理
iptables -t nat -D PREROUTING -p tcp -j CLASH || echo '无规则需要清理--跳过'
iptables -t nat -I PREROUTING -p tcp -j CLASH # 在 PREROUTING 链的最前面插入 CLASH 链

# 如果需要拦截入口收到的DNS请求，需要配置下面
iptables -t nat -N CLASH_DNS || echo 'CLASH_DNS链已存在--即将清空'
iptables -t nat -F CLASH_DNS
iptables -t nat -A CLASH_DNS -p udp -i docker0 -j RETURN # docker容器的dns跳过
iptables -t nat -A CLASH_DNS -p udp -j REDIRECT --to-port 53
iptables -t nat -D PREROUTING -p udp --dport 53 -j CLASH_DNS || echo '无规则需要清理--跳过'
iptables -t nat -I PREROUTING -p udp --dport 53 -j CLASH_DNS

iptables -t nat -L -v -n
