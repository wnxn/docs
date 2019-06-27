# Git

## 删除远程分支

- origin： 为本地配置远程仓库名，
- volume-types: 为远程分支名

```
git push origin --delete volume-types
```


## PR 方式开发流程

### 前提条件
- fork 公共远端仓库到个人远端仓库

- 本地仓库设置了 upstream 和 origin
```
$ git remote -v
origin  https://github.com/wnxn/QKE.git (fetch)
origin  https://github.com/wnxn/QKE.git (push)
upstream        https://github.com/QingCloudAppcenter/QKE.git (fetch)
upstream        https://github.com/QingCloudAppcenter/QKE.git (push)
```

### 执行步骤

- 提 Issue，开发者按照 Issue 来开发

- 开发者切换到 master 分支
```
$ git branch -a
$ git checkout master
```

- 开发者仓库同步 
```
$ git pull upstream master
$ git push origin master
```

- 开发者本地新建开发 Issue 分支
```
$ git checkout master
$ git checkout -b NEW_FEATURE origin/master
Branch 'NEW_FEATURE' set up to track remote branch 'master' from 'origin'.
Switched to a new branch 'NEW_FEATURE'
```

- 开发者检查 NEW_FEATURE
```
$ git branch -a
* NEW_FEATURE
  master
```

- 开发者上传到远端个人 fork 的仓库
```
git push origin NEW_FEATURE
```

- 开发者 Github 提 PR  upstream:master <- origin:NEW_FEATURE

- 审核者 Github 审核和 squash 方式合并 PR

- 批准 PR 后开发者删除新建的分支