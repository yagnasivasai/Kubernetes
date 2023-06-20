 how can I change pod QoS Class: Burstable to Guaranteed ?
 
For a Pod to be given a QoS class of Guaranteed:
Every Container in the Pod must have a memory limit and a memory request.
For every Container in the Pod, the memory limit must equal the memory request.
Every Container in the Pod must have a CPU limit and a CPU request.
For every Container in the Pod, the CPU limit must equal the CPU request.

https://kubernetes.io/docs/tasks/configure-pod-container/quality-service-pod/#create-a-pod-that-gets-assigned-a-qos-class-of-guaranteed

https://kubernetes.io/docs/tasks/debug/debug-application/debug-running-pod/#node-shell-session


Blocking attacker IPs in iptables on k8s hosts - automation using fail2ban
Hi Team,
I have a k8s cluster hosted on a cloud platform without any cloud based firewall.
I am trying to understand how can I add a rule in iptabels which will take priority before kube-proxy or docker iptables rules.
These will be standard reject rule for IPs attacking my k8s nodes.
I am also looking at a way to automate this using fail2ban to block traffic from attacker.
any guidance appreciated. (edited) 


You're better off using a bastion host or VPN. Do not directly expose your Kubernetes cluster on the public network
I would also suggest you to not mess with the linux firewall on the nodes themselves. Instead you should use a cloud firewall or limited network of some sorts.
https://github.com/a-bouts/fail2ban-calico
I don't think Calico has fail2ban capability built in. You can use Calico's implementation of NetworkPolicy to ban hosts,
but fail2ban as an application does not conform with this model whatsoever.


If I do not assign CPU and memory limit in a pod definition then by default can pod use all resource available with the Node or there is some default restrictions?
depends on your cluster configuration. But by default there should be no cluster-wide policies
So, yes the pod could end up draining your resources and even slow down your whole node, and even affect whole cluster


can anyone please help me.
I need to create a URL domain.com:port  but in ingress it is not possible, is there a way  I can do this?.
Ingress resource file will not have domain mappings only host and path rules. Ingress provisions a LB behind the scenes for most cloud providers 
so you need to map the IP of the LB  to domain name in your domain provider 
like Godaddy etc
The service of type LoadBalancer is designed for that. It can proxy and incoming port to your application, 
however afaik it will not check your domain (Host http header), which means all Layer 4 traffic on that port gets routed.
I would use Ingress on port 443 (HTTPS) with the Ingress resource. You can proxy a sub path /myapp to your application.



I’m new in the cloud world. I’ve developed several microservices that I want to deploy to production. But, there’re some problems:
What’s the best practice to not expose a service/port/endpoint to the outside, but still make accessible for me as a developer. 
Such a service could be database or any monitoring service.

https://aws.github.io/aws-eks-best-practices/security/docs/network/#create-a-default-deny-policy



I got a really dumb question. A tool I use relies on the existence of the ~/.kube/config  file as its generally meant to be used as a CLI tool. I am wanting to run it as a cronjob inside k8. Is there an easy way to create.
Is there an easy way to create that file besides manually creating it?
The manual way being getting the token, storing that in a secure keystore and during the init of the job creating the file pulling that value
from the keystore and inserting it into the config file.
aws eks update-kubeconfig? (edited) 
https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html


https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/job-v1/#create-create-a-job
what is the API to call to trigger a job run?
You can trigger the cronjob by creating a job with reference to the cronjob. In the body of the API call, you will need to include the following in the metadata
  ownerReferences:
  - apiVersion: batch/v1
    kind: CronJob
    name: <>
   
If this helps in constructing the body
kubectl create job <job name> --from=cronjob/<cronjob name> --dry-run=client -o json
  
https://github.com/flant/shell-operator Custom Operator
  

  I'm running two pods
one is the python and has api.
I ran command,
kubectl port-forward --address my_ip first_pod 8000
Second is the WebSocket server and WebSocket client inside the pod. It also has the python to communicate with the #1 pod.
I also ran the command,
kubectl port-forward --address my_ip second_pod 8080
Python is able to communicate without any issues.
Second pod is able to access to API without any issues. The two web sockets (client and server) inside the pod couldn't reach to each other.
Was I supposed to run port-forward too?
  
  ![image](https://user-images.githubusercontent.com/60940642/211732088-9f04a29a-b3c4-4e22-b0bd-09e742a5b278.png)
  
  The client has this export var websocket_url = "ws://127.0.0.1:9050"
And the python has this,
websockets.serve(echo, os.getenv("k8_server"), configuration.network_settings['godot_websocket_port'],
  In yaml of deployment:
- name: k8_server
  value: "0.0.0.0"
  Change the value to 127.0.0.1
  
  nc -vz localhost 8080
  curl -v localhost:8080
  
  
  
  We have 4 nodes EKS cluster. We have some pods (part of Daemonset) in pending status as the Node is full and there is no capacity in the node to run any new pod. The question is do we need to manually reshuffle the workloads to make Daemonset's pod running in this situation or is there any configuration to overcome this issue in an automated fashion?
Thank you in advance.
  
 https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/
  
https://kubernetes.github.io/ingress-nginx/deploy/#quick-start
  Nginx
  

Hi All, I have one mariadb instance in a pod. How can I clear the data within one of the table of mariadb every midnight?
  I've not used mariaDB in my kube environment but one option for doing this may be:
https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/
with the job itself defined via https://kubernetes.io/docs/concepts/workloads/controllers/job/
  
  
  
