#!/bin/sh

# scripts/iptables-down.up


iptables -t nat -D PREROUTING -p tcp -j CLASH
iptables -t nat -X CLASH
iptables -t nat -D PREROUTING -p udp --dport 53 -j CLASH_DNS
iptables -t nat -X CLASH_DNS
echo 'iptables 已清理'
