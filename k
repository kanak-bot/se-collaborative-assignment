Kubernetes command sequence:minikube start --driver=docker
minikube status

kubectl create deployment mynginx --image=nginx
kubectl get deployments
kubectl get pods
kubectl describe pods

kubectl expose deployment mynginx --type=NodePort --port=80 --target-port=80

kubectl scale deployment mynginx --replicas=4
kubectl get pods

kubectl port-forward svc/mynginx 8081:80                                Nagios command sequence:                                            docker pull jasonrivers/nagios:latest
docker run --name nagiosdemo -p 8888:80 jasonrivers/nagios:latest
docker ps
docker logs -f nagiosdemo
docker stop nagiosdemo
docker rm nagiosdemo
docker rmi jasonrivers/nagios:latest
