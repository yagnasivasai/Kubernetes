kubectl create deployment first-deployment --image=nginx
kubectl get pods

#Once the container is running it can be exposed via different networking options, depending on requirements. One possible solution is NodePort, that provides a dynamic port to a container

kubectl expose deployment first-deployment --port=80 --type=LoadBalancer

The command below finds the allocated port and executes a HTTP request
export PORT=$(kubectl get svc first-deployment -o go-template='{{range.spec.ports}}{{if .LoadBalancer}}{{.LoadBalancer}}{{"\n"}}{{end}}{{end}}')

echo "Accessing host01:$PORT"

curl host01:$PORT
