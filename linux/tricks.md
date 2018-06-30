# Files

## find files containing words

```
grep -R --include="*.go" storage-class ./
```

## save files

```
cat <<EOF | sudo tee /the/file/path/filename
file context...
EOF
```

# Volume

## Mount table

```
cat /proc/mounts
```

# Go

## Test one testfile

```
go test -v mount_test.go -count=1
```

# CSI

## csi-test

```
./csi-sanity --endpoint=csi_endpoint=unix://var/lib/kubelet/plugins/csi-qingcloud/csi.sock
```
