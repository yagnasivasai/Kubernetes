## Istio Installation

curl -L https://istio.io/downloadIstio | sh -

export PATH="$PATH:/tmp/shiva/istio/istio-1.17.1/bin"

istioctl x precheck

istioctl install

kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.17/samples/addons/kiali.yaml

kubectl get pods -n istio-system

kubectl get pods -n istio-system -w

kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.17/samples/addons/grafana.yaml

kubectl get pods -n istio-system -w

kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.17/samples/addons/prometheus.yaml

kubectl get ns

kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.17/samples/addons/jaeger.yaml


kubectl describe ns default

kubectl label namespace default istio-injection=enabled

kubectl describe ns default



http://192.168.0.149:30080/