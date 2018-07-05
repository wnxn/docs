## Smoke test
* [ ] Create a RWO PVC which name is pvc-rwo-1
* [ ] Create a deployment which mount pvc-rwo-1 at mnt directory
* [ ] Write a file in mnt directory
* [ ] Scale down deployment replication from 1 to 0
* [ ] Scale up deployment replication from 0 to 1
* [ ] Read and write the file in mnt directory
* [ ] Scale up deployment replications from 1 to 5
* [ ] Read and write the file in mnt directory
* [ ] Scale down deployment replications from 5 to 3
* [ ] Scale down deployment replications from 3 to 1
* [ ] If the pod scheduled to another node, read and write the file in mnt directory
* [ ] Delete the deployment
* [ ] Set spec.volume.persistentVolumeClaims.readOnly or  spec.containers.volumeMount.readOnly equal to true in deployment.
* [ ] Expect the file only readable in mnt directory
* [ ] Delete the pvc-rwo-1 PVC
* [ ] Create a RWX PVC which name is pvc-rwx-1, expect creating failed
* [ ] Create a ROX PVC which name is pvc-rox-1, expect creating failed