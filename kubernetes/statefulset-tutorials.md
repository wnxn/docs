# statefulset
https://kubernetes.io/docs/tutorials/stateful-application/basic-stateful-set/
## statefulset基础
- 有创建，删除，伸缩，升级动作
- 创建statefulset一般需要创建持久卷（两种方法，动态提供PV，静态提供PV，手动分配）

### 滚动升级
- kubectl patch
- kubectl rollout status 
