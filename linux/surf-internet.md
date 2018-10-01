# Install ShadowSocks

```
# apt-get install shadowsocks -y
```

# Config ShadowSocks

```
cat /etc/shadowsocks/config.json 
{
    "server":"1.1.1.1",
    "server_port":8388,
    "local_address": "127.0.0.1",
    "local_port":1080,
    "password":"password",
    "timeout":300,
    "method":"aes-256-cfb"
}
```

# sslocal

```
nohup sslocal -c /etc/shadowsocks/config.json 2>&1 &
```

# Install Polipo

```
# apt-get install polipo -y
```


# Config Polipo

```
cat /etc/polipo/config 
# This file only needs to list configuration variables that deviate
# from the default values.  See /usr/share/doc/polipo/examples/config.sample
# and "polipo -v" for variables you can tweak and further information.

logSyslog = true
logFile = /var/log/polipo/polipo.log
socksParentProxy = "localhost:1080"
proxyPort = 8787

```

# Config Env

```
cat /etc/profile
export http_proxy=http://127.0.0.1:8787
export https_proxy=http://127.0.0.1:8787
```

# Docker Proxy

> https://docs.docker.com/config/daemon/systemd/#httphttps-proxy