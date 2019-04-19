1. iptables
```
iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X
```

1. ipvs
```
ipvsadm --clear
```
