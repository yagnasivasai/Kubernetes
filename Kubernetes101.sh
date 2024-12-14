
export NODE=$(kubectl get node -o name | cut -d / -f 2 | head -1)

kubectl get node "$NODE" -o json \
  | jq '.status | {capacity, allocatable}
        | [ to_entries[] | .value |= {cpu, memory} ]
        | from_entries'
		


kubectl describe node "$NODE" \
>   | awk '/Name:/{print "\n"$1, $2} /Allocated/{p=1} /storage/{p=0} p'
		
kubectl get pods --all-namespaces --field-selector \
  status.phase!=Terminated,status.phase!=Succeeded,status.phase!=Failed,spec.nodeName="$NODE"
  

kubectl get pods --all-namespaces -o json --field-selector \
  status.phase!=Terminated,status.phase!=Succeeded,status.phase!=Failed,spec.nodeName="$NODE" \
  | jq '[ .items[].spec.containers[].resources.requests.cpu // "0"
          | if endswith("m")
            then (rtrimstr("m") | tonumber / 1000)
            else (tonumber) end
        ] | add * 1000 | round | "\(.)m"'
  

{ kubectl get node "$NODE" -o json; \
    kubectl get pods --all-namespaces -o json --field-selector \
      status.phase!=Terminated,status.phase!=Succeeded,status.phase!=Failed,spec.nodeName="$NODE"; } \
  | jq -s '( .[0].status.allocatable.cpu
             | if endswith("m")
               then (rtrimstr("m") | tonumber / 1000)
               else (tonumber) end
           ) as $allocatable
           | ( [ .[1].items[].spec.containers[].resources.requests.cpu // "0"
                 | if endswith("m")
                   then (rtrimstr("m") | tonumber / 1000)
                   else (tonumber) end
               ] | add
             ) as $allocated
           | ($allocatable - $allocated) * 1000 | round
           | "\(.)m is available"'
		   
		   
___________________________________________________________________________________________________________________________________________________________________________

kubectl create configmap demo-config --from-literal=example.key="Initial Value"
kubectl run nginx-pod --image=nginx --restart=Never --port=80 -n default
kubectl run nginx --image=nginx --type=NodePort --port=80 --dry-run=client -o yaml > nginx.yaml
---
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx
spec:
  containers:
  - image: nginx
    name: nginx
    env:
    - name: EXAMPLE_KEY
      valueFrom: 
        configMapKeyRef:
          name: demo-config
          key: example.key
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-svc
  labels:
    app: nginx
spec:
  type: NodePort
  selector:
    app: nginx
  ports:
    - port: 80
      targetPort: 80
---
kubectl exec nginx -- env | grep EXAMPLE_KEY
kubectl patch configmap demo-config -p '{"data":{"example.key":"First Update:env variables"}}'
_________________________________________________________________________________________________________________________________________________________________________________________________

apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx-config-pod
  name: nginx-config-pod
spec:
  containers:
  - image: nginx
    name: nginx
    resources: {}
    volumeMounts:
    - name: config-volume
      mountPath: /etc/config
  dnsPolicy: ClusterFirst
  restartPolicy: Always
  volumes:
  - name: config-volume
    configMap:
      name: demo-config
status: {}


