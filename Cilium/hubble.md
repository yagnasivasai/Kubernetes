---
kubectl exec -n kube-system cilium-khpmt -- hubble status
kubectl exec -n kube-system cilium-khpmt -- cilium status

kubectl exec -n kube-system cilium-khpmt -- hubble observe --last 10
kubectl portforward -n kube-system svc/hubble-relay --address 0.0.0.0 4245:80