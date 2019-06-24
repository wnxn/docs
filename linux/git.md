# Git

## 删除远程分支

- origin： 为本地配置远程仓库名，
- volume-types: 为远程分支名

```
git push origin --delete volume-types
```


## 开发流程

- 提 Issue

- 仓库同步 
```
$ git pull upstream master
$ git push origin master
```

- 本地新建开发 Issue 分支
```
$ git checkout master
$ git checkout -b expand-volume origin/master
Branch 'expand-volume' set up to track remote branch 'master' from 'origin'.
Switched to a new branch 'expand-volume'

```