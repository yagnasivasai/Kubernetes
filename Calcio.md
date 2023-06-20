###

+ https://snapcraft.io/docs/installing-snapd


###

+ kubectl apply -f https://raw.githubusercontent.com/tigera/ccol1/main/yaobank.yaml
+ kubectl rollout status -n yaobank deployment/customer
+ kubectl rollout status -n yaobank deployment/summary
+ kubectl rollout status -n yaobank deployment/database
+ curl 198.19.0.1:30180
+ - The Kubernetes network model does specify that pods can communicate with each other directly without NAT. But a pod communicating with another pod via a service is not direct communication, and normally will use NAT to change the connection destination from the service to the backing pod as part of load balancing.
+ kubectl get pods -n yaobank -o wide


### Week 2 Network Policy

