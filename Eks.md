Istio 1.17.1 Download Complete!

Istio has been successfully downloaded into the istio-1.17.1 folder on your system.

Next Steps:
See https://istio.io/latest/docs/setup/install/ to add Istio to your Kubernetes cluster.

To configure the istioctl client tool for your workstation,
add the /tmp/shiva/istio/istio-1.17.1/bin directory to your environment path variable with:
         export PATH="$PATH:/tmp/shiva/istio/istio-1.17.1/bin"

Begin the Istio pre-installation check by running:
         istioctl x precheck

Need more information? Visit https://istio.io/latest/docs/setup/install/


k3d cluster create wasm-cluster --image ghcr.io/deislabs/containerd-wasm-shims/examples/k3d:v0.5.1 -p "8081:80@loadbalancer" --agents 2


eksctl create cluster --name=sigle \
                      --region=ap-south-1 \
                      --zones=ap-south-1a,ap-south-1b \
                      --without-nodegroup

eksctl utils associate-iam-oidc-provider \
    --region ap-south-1 \
    --cluster sigle \
    --approve
    
eksctl create nodegroup --cluster=sigle \
                       --region=ap-south-1 \
                       --name=sigle-ng-public1 \
                       --node-type=t2.micro \
                       --nodes=1 \
                       --nodes-min=1 \
                       --nodes-max=2 \
                       --node-volume-size=20 \
                       --ssh-access \
                       --ssh-public-key=minikube \
                       --managed \
                       --asg-access \
                       --external-dns-access \
                       --full-ecr-access \
                       --appmesh-access \
                       --alb-ingress-access
                       
eksctl get clusters
eksctl get nodegroup --cluster=sigle

eksctl delete nodegroup --cluster=sigle --name=sigle-ng-public1
eksctl delete cluster sigle

kubectl create service nodeport ns-service --tcp=80:80 --dry-run=client -o yaml
kubectl create deployment nginx --image=nginx --dry-run=client -o yaml > deploy.yaml
kubectl run nginx --image=nginx --dry-run=client -o yaml > pod.yaml

kubectl scale deployment --replicas=2
kubectl edit deployment deploymentname
kubectl get deployment

## Rolling update
kubectl set image deployment nginx=nginx:v2
kubectl rollout status deployment
kubectl rollout undo deployment


apiVersion: batch/v1
kind: Job
metadata:
  name: pi
spec:
  template:
    spec:
      containers:
      - name: pi
        image: perl:5.34.0
        command: ["perl",  "-Mbignum=bpi", "-wle", "print bpi(2000)"]
      restartPolicy: Never // Will not retart if job fails or success
  backoffLimit: 4 # Retriesfor 4 times if command fails
  activeDeadlineSeconds: 10 # Maximum time a Job can run
  ttlSecondsAfterFinished: 100 # Clean the Job and its dependencies
  
  
apiVersion: batch/v1
kind: CronJob
metadata:
  name: hello
spec:
  schedule: "*/1 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: hello
            image: busybox:stable
            imagePullPolicy: IfNotPresent
            command:
            - /bin/sh
            - -c
            - date; echo Hello from the Kubernetes cluster
          restartPolicy: OnFailure
      backoffLimit: 4
      activeDeadlineSeconds: 5
      ttlSecondsAfterFinished: 0

# ┌───────────── minute (0 - 59)
# │ ┌───────────── hour (0 - 23)
# │ │ ┌───────────── day of the month (1 - 31)
# │ │ │ ┌───────────── month (1 - 12)
# │ │ │ │ ┌───────────── day of the week (0 - 6) (Sunday to Saturday;
# │ │ │ │ │                                   7 is also Sunday on some systems)
# │ │ │ │ │                                   OR sun, mon, tue, wed, thu, fri, sat
# │ │ │ │ │
# * * * * *
          
   
   
   
