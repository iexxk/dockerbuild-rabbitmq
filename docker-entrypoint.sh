#!/bin/sh
tc qd add dev eth0 root handle 1: tbf rate $NETSIZE burst $NETBURST latency $NETDELAY
exec "$@"
