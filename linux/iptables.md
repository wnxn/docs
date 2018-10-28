# iptables
## show rule
```
iptables -t nat -L -n --line-number
```

## delete rule
```
iptables -t nat -D PREROUTING 1
```