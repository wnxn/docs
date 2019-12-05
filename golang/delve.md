# Remote debug in Goland

https://blog.jetbrains.com/go/2019/02/06/debugging-with-goland-getting-started/

## Install
- gops: go get -u github.com/google/gops
- dlv: go get -u github.com/go-delve/delve/cmd/dlv
https://github.com/go-delve/delve/blob/master/Documentation/installation/linux/install.md

## Configure In Local Goland


## In Remote Host
```
cd $GOPATH/src/github.com/xxx
GO111MODULE=on dlv debug --headless --listen=:2345 --api-version=2 --accept-multiclient
```

## Reference
- Delve: https://github.com/go-delve/delve
- Debug in Goland: https://blog.jetbrains.com/go/2019/02/06/debugging-with-goland-getting-started/
- Gops: https://github.com/google/gops