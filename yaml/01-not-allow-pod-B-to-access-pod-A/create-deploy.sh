kubectl run nginx --image=nginx
kubectl expose deploy nginx --port 8080 --target-port 80
