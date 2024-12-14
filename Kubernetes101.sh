
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

kubectl create configmap demo-config - from-literal=example.key="Initial Value"
