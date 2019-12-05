# Unittest
```
go test -run CharCount
```

## Find external test

```
go list -f={{.GOFiles}} fmt
go list -f={{.TestGoFiles}} fmt
go list -f={{.XTestGoFiles}} fmt
```

## Coverage


```
go test -run CharCount -coverprofile=c.out
go tool cover -html=c.out
```

# Benchmark

```
go test -bench=.
go test -bench=. -benchmem
```