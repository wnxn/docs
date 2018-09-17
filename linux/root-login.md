## login root
```
sudo -i
```

## modify configuration
```
sudo vi /etc/ssh/sshd_config

LoginGraceTime 120
PermitRootLogin yes
StrictModes yes
```

## restart service
```
service ssh restart
```
