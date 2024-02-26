To learn how to use and enforce policies with Cilium, we have prepared a demo example.

In the following Star Wars-inspired example, there are three microservice applications: deathstar, tiefighter, and xwing.


kubectl apply -f https://raw.githubusercontent.com/cilium/cilium/HEAD/examples/minikube/http-sw-app.yaml
kubectl get cep --all-namespaces
kubectl get pods,svc


kubectl exec tiefighter -- \
  curl -s -XPOST deathstar.default.svc.cluster.local/v1/request-landing

kubectl exec xwing -- \
  curl -s -XPOST deathstar.default.svc.cluster.local/v1/request-landing

###
Identities and Cloud Native
IP addresses are no longer relevant for Cloud Native workloads. Security policies need something else.

Cilium provides this: Cilium uses the labels assigned to pods to define security policies.


spec:
  description: "L3-L4 policy to restrict deathstar access to empire ships only"
  endpointSelector:
    matchLabels:
      org: empire
      class: deathstar

  ingress:
  - fromEndpoints:
    - matchLabels:
        org: empire
    toPorts:
    - ports:
      - port: "80"
        protocol: TCP


apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: rule1
spec:
  endpointSelector:
    matchLabels:
      org: empire
      class: deathstar
  ingress:
    - fromEndpoints:
        - matchLabels:
            org: empire
      toPorts:
        - ports:
            - port: "80"
              protocol: TCP


kubectl apply -f https://raw.githubusercontent.com/cilium/cilium/HEAD/examples/minikube/sw_l3_l4_policy.yaml


kubectl exec tiefighter -- \
  curl -s -XPOST deathstar.default.svc.cluster.local/v1/request-landing

kubectl exec xwing -- \
  curl -s -XPOST deathstar.default.svc.cluster.local/v1/request-landing



###
So far it was sufficient to either give tiefighter/xwing full access to deathstar’s API or no access at all. But are you absolutely sure that you can trust all thousands of tiefighter pilots of the entire empire?

We must provide the strongest security (i.e., enforce least-privilege isolation) between microservices: each service that calls deathstar’s API should be limited to making only the set of HTTP requests it requires for legitimate operation.


kubectl exec tiefighter -- \
  curl -s -XPUT deathstar.default.svc.cluster.local/v1/exhaust-port

kubectl exec tiefighter -- \
  curl -s -XPUT deathstar.default.svc.cluster.local/v1/exhaust-port

apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: rule1
spec:
  endpointSelector:
    matchLabels:
      org: empire
      class: deathstar
  ingress:
    - fromEndpoints:
        - matchLabels:
            org: empire
      toPorts:
        - ports:
            - port: "80"
              protocol: TCP
          rules:
            http:
              - method: POST
                path: /v1/request-landing

kubectl apply -f https://raw.githubusercontent.com/cilium/cilium/HEAD/examples/minikube/sw_l3_l4_l7_policy.yaml

kubectl exec tiefighter -- curl -s -XPUT deathstar.default.svc.cluster.local/v1/exhaust-port


In the </> Editor tab, the sneak.yaml file has been pre-created but is missing the right parameters.
The policy has been loaded in the 🔗 Network Policy Editor tab. You can also open it in a new tab if necessary.
Make sure to apply the policy file in the >_ Terminal tab!
Your organization is called empire, you only want to allow ships of the class tiefighter
The endpoint the ships should reach is of the class deathstar, and of the organization empire
We also want to limit to port 80 and the TCP protocol.
Test TIE fighter access with kubectl exec tiefighter -- curl -s -XPOST deathstar.default.svc.cluster.local/v1/request-landing
Test X-Wing access with kubectl exec xwing -- curl -s -XPOST deathstar.default.svc.cluster.local/v1/request-landing
In the second tab, you can find the network policy editor which can help you creating the necessary rule.
You might find Cilium documentation about L3/L4 policies helpful
When the policy is updated, apply it with kubectl apply -f /root/policies/sneak.yaml


kubectl exec tiefighter -- curl -s -XPOST deathstar.default.svc.cluster.local/v1/request-landing
kubectl exec xwing -- curl -s -XPOST deathstar.default.svc.cluster.local/v1/request-landing
--------------------------------------------------------------------------------------------------------------------------------

Your lab environment is currently being set up. Stay tuned!

In the meantime, let's review what we will go through today:

Cilium Installation with Gateway API
HTTP Traffic Management with Gateway API
HTTPS Traffic Management with Gateway API
TLS Passthrough with Gateway API
HTTP Load Balancing with Gateway API
Please click the arrow on the right to proceed.

🤹🏼‍♂️ Embedded Envoy Proxy
Cilium already uses Envoy for L7 policy and observability for some protocols, and this same component is used as the sidecar proxy in many popular Service Mesh implementations.

So it's a natural step to extend Cilium to offer more of the features commonly associated with Service Mesh —though contrary to other solutions, without the need for any pod sidecars.

Instead, this Envoy proxy is embedded with Cilium, which means that only one Envoy container is required per node.
In a typical Service Mesh, all network packets need to pass through a sidecar proxy container on their path to or from the application container in a Pod.

This means each packet traverses the TCP/IP stack three times before even leaving the Pod

In Cilium Service Mesh, we’re moving that proxy container onto the host and kernel so that sidecars for each application pod are no longer required.

Because eBPF allows us to intercept packets at the socket as well as at the network interface, Cilium can dramatically shorten the overall path for each packet.


--------
Before we can install Cilium with the Gateway API feature, there are a couple of important prerequisites to know:

Cilium must be configured with kubeProxyReplacement set to true.

CRD (Custom Resource Definition) from Gateway API must be installed beforehand.

As part of the lab deployment script, several CRDs were installed. Verify that they are available.

kubectl get crd \
  gatewayclasses.gateway.networking.k8s.io \
  gateways.gateway.networking.k8s.io \
  httproutes.gateway.networking.k8s.io \
  referencegrants.gateway.networking.k8s.io \
  tlsroutes.gateway.networking.k8s.io


cilium config view | grep -w "enable-gateway-api"


The GatewayClass is a type of Gateway that can be deployed: in other words, it is a template. This is done in a way to let infrastructure providers offer different types of Gateways. Users can then choose the Gateway they like.

For instance, an infrastructure provider may create two GatewayClasses named internet and private to reflect Gateways that define Internet-facing vs private, internal applications.

In our case, the Cilium Gateway API (io.cilium/gateway-controller) will be instantiated.

This schema below represents the various components used by Gateway APIs. When using Ingress, all the functionalities were defined in one API. By deconstructing the ingress routing requirements into multiple APIs, users benefit from a more generic, flexible and role-oriented model.

The actual L7 traffic rules are defined in the HTTPRoute API.

In the next challenge, you will deploy an application and set up GatewayAPI HTTPRoutes to route HTTP traffic into the cluster.

The Cilium Service Mesh Gateway API Controller requires the ability to create LoadBalancer Kubernetes services.

Since we are using Kind on a Virtual Machine, we do not benefit from an underlying Cloud Provider's load balancer integration.

For this lab, we will use Cilium's own LoadBalancer capabilities to provide IP Address Management (IPAM) and Layer 2 announcement of IP addresses assigned to LoadBalancer services.

You can check the Cilium LoadBalancer IPAM and L2 Service Announcement lab to learn more about it.

yq basic-http.yaml

###


First, note in the Gateway section that the gatewayClassName field uses the value cilium. This refers to the Cilium GatewayClass previously configured.

The Gateway will listen on port 80 for HTTP traffic coming southbound into the cluster. The allowedRoutes is here to specify the namespaces from which Routes may be attached to this Gateway. Same means only Routes in the same namespace may be used by this Gateway.

Note that, if we were to use All instead of Same, we would enable this gateway to be associated with routes in any namespace and it would enable us to use a single gateway across multiple namespaces that may be managed by different teams.

We could specify different namespaces in the HTTPRoutes – therefore, for example, you could send the traffic to https://acme.com/payments in a namespace where a payment app is deployed and https://acme.com/ads in a namespace used by the ads team for their application.

Let's now review the HTTPRoute manifest. HTTPRoute is a GatewayAPI type for specifiying routing behaviour of HTTP requests from a Gateway listener to a Kubernetes Service.

It is made of Rules to direct the traffic based on your requirements.

This first Rule is essentially a simple L7 proxy route: for HTTP traffic with a path starting with /details, forward the traffic over to the details Service over port 9080

###
The second rule is similar but it's leveraging different matching criteria. If the HTTP request has:

a HTTP header with a name set to magic with a value of foo, AND
the HTTP method is "GET", AND
the HTTP query param is named great with a value of example, Then the traffic will be sent to the productpage service over port 9080.


GATEWAY=$(kubectl get gateway my-gateway -o jsonpath='{.status.addresses[0].value}')
echo $GATEWAY

kubectl get gateway


curl --fail -s http://$GATEWAY/details/1 | jq


curl -v -H 'magic: foo' "http://$GATEWAY?great=example"

###
mkcert '*.cilium.rocks'
kubectl create secret tls demo-cert \
  --key=_wildcard.cilium.rocks-key.pem \
  --cert=_wildcard.cilium.rocks.pem

mkcert -install

curl -s \
  --resolve bookinfo.cilium.rocks:443:${GATEWAY_IP} \
  https://bookinfo.cilium.rocks/details/1 | jq


###
TLSRoute

In the previous task, we looked at the TLS Termination and how the Gateway can terminate HTTPS traffic from a client and route the unencrypted HTTP traffic based on HTTP properties, like path, method or headers.

In this task, we will look at a feature that was introduced in Cilium 1.14: TLSRoute. This resource lets you passthrough TLS traffic from the client all the way to the Pods - meaning the traffic is encrypted end-to-end.

kubectl create configmap nginx-configmap --from-file=nginx.conf=./nginx.conf


Earlier you saw how you can terminate the TLS connection at the Gateway. That was using the Gateway API in Terminate mode. In this instance, the Gateway is in Passthrough mode: the difference is that the traffic remains encrypted all the way through between the client and the pod.

In other words:

In Terminate:

Client -> Gateway: HTTPS
Gateway -> Pod: HTTP
In Passthrough:

Client -> Gateway: HTTPS
Gateway -> Pod: HTTPS

The Gateway does not actually inspect the traffic aside from using the SNI header for routing. Indeed the hostnames field defines a set of SNI names that should match against the SNI attribute of TLS ClientHello message in TLS handshake.



Let's also double check the TLSRoute has been provisioned successfully and has been attached to the Gateway.
kubectl get tlsroutes.gateway.networking.k8s.io -o json | jq '.items[0].status.parents[0]'

curl -v \
  --resolve "nginx.cilium.rocks:443:$GATEWAY_IP" \
  "https://nginx.cilium.rocks:443"


  The data should be properly retrieved, using HTTPS (and thus, the TLS handshake was properly achieved).

  There are several things to note in the output.

  It should be successful (you should see at the end, a HTML output with Cilium rocks.).
  The connection was established over port 443 - you should see Connected to nginx.cilium.rocks (172.18.255.200) port 443 .
  You should see TLS handshake and TLS version negotiation. Expect the negotiations to have resulted in TLSv1.3 being used.
  Expect to see a successful certificate verification (look out for SSL certificate verify ok).

###
🪓 Traffic splitting
Cilium Gateway API comes fully integrated with a HTTP traffic splitting engine.

In order to introduce a new version of an app, operators would often start pushing some traffic to a new backend and see how users react and how the app fares under load. It’s also known as A/B testing, blue-green deployments or canary releases.

You can now do it natively, with Cilium Gateway API weights. No need to install another tool or Service Mesh.

kubectl apply -f echo-servers.yaml

kubectl apply -f load-balancing-http-route.yaml

curl --fail -s http://$GATEWAY/echo

for _ in {1..500}; do
  curl -s -k "http://$GATEWAY/echo" >> curlresponses.txt;
done

grep -o "Hostname: echo-." curlresponses.txt | sort | uniq -c


