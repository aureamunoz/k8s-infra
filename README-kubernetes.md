### How to setup a kubernetes cluster on Centos7

Useful links

- https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/#master-isolation
- https://powerodit.ch/2017/10/29/all-in-one-kubernetes-cluster-with-kubeadm/
- https://kubernetes.io/docs/setup/independent/install-kubeadm/
- https://kubernetes.io/docs/concepts/cluster-administration/addons/
- https://ichbinblau.github.io/2017/09/20/Setup-Kubernetes-Cluster-on-Centos-7-3-with-Kubeadm/

### Add yum repo & install kubelet, kubeadm and kubectl
```
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kube*
EOF

yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
```

### Disable SELINUX

```
sed -i 's/^SELINUX=enforcing$/SELINUX=disabled/' /etc/selinux/config
```

### Pass bridged IPv4 traffic to iptables

Set `/proc/sys/net/bridge/bridge-nf-call-iptables` to `1` by running `sysctl net.bridge.bridge-nf-call-iptables=1` to pass bridged IPv4 traffic to iptables’ chains. This is a requirement for some CNI plugins to work, for more information please see here.

```
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables
or
sysctl net.bridge.bridge-nf-call-iptables=1
```

TODO: TO BE CHECKED
```
cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl -p
```

[see](https://github.com/kubernetes/kubeadm/issues/312#issuecomment-429828991)


### Start kubelet
```
systemctl start kubelet
kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=192.168.99.50
```

Output
```
[root@cloud ~]# kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=192.168.99.50
[init] Using Kubernetes version: v1.14.1
[preflight] Running pre-flight checks
  [WARNING Service-Kubelet]: kubelet service is not enabled, please run 'systemctl enable kubelet.service'
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Activating the kubelet service
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "front-proxy-ca" certificate and key
[certs] Generating "front-proxy-client" certificate and key
[certs] Generating "etcd/ca" certificate and key
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [cloud localhost] and IPs [192.168.99.50 127.0.0.1 ::1]
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [cloud localhost] and IPs [192.168.99.50 127.0.0.1 ::1]
[certs] Generating "etcd/healthcheck-client" certificate and key
[certs] Generating "apiserver-etcd-client" certificate and key
[certs] Generating "ca" certificate and key
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [cloud kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 192.168.99.50]
[certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Generating "sa" key and public key
[kubeconfig] Using kubeconfig folder "/etc/kubernetes"
[kubeconfig] Writing "admin.conf" kubeconfig file
[kubeconfig] Writing "kubelet.conf" kubeconfig file
[kubeconfig] Writing "controller-manager.conf" kubeconfig file
[kubeconfig] Writing "scheduler.conf" kubeconfig file
[control-plane] Using manifest folder "/etc/kubernetes/manifests"
[control-plane] Creating static Pod manifest for "kube-apiserver"
[control-plane] Creating static Pod manifest for "kube-controller-manager"
[control-plane] Creating static Pod manifest for "kube-scheduler"
[etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
[wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s
[apiclient] All control plane components are healthy after 17.003335 seconds
[upload-config] storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config-1.14" in namespace kube-system with the configuration for the kubelets in the cluster
[upload-certs] Skipping phase. Please see --experimental-upload-certs
[mark-control-plane] Marking the node cloud as control-plane by adding the label "node-role.kubernetes.io/master=''"
[mark-control-plane] Marking the node cloud as control-plane by adding the taints [node-role.kubernetes.io/master:NoSchedule]
[bootstrap-token] Using token: om9c9r.3pid52k7xqyymqd4
[bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
[bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstrap-token] creating the "cluster-info" ConfigMap in the "kube-public" namespace
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.99.50:6443 --token om9c9r.3pid52k7xqyymqd4 \
    --discovery-token-ca-cert-hash sha256:14779e32e999d46c4034a86751841e9b67211d90f3f254f6b22127d303e7e037
```

# Create kube config file
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config  
```

# Check if the pods are running
```
kubectl get pods -A
NAMESPACE     NAME                            READY   STATUS    RESTARTS   AGE
kube-system   coredns-fb8b8dccf-4p6m7         0/1     Pending   0          22m
kube-system   coredns-fb8b8dccf-dl8kt         0/1     Pending   0          22m
...
```

The coreDNS are pending has the pod was not tainted, [See](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/#control-plane-node-isolation)

```
kubectl describe pods/coredns-fb8b8dccf-4p6m7 -n kube-system
Name:               coredns-fb8b8dccf-4p6m7
Namespace:          kube-system
Priority:           2000000000
PriorityClassName:  system-cluster-critical
Node:               <none>
Labels:             k8s-app=kube-dns
                    pod-template-hash=fb8b8dccf
Events:
  Type     Reason            Age                 From               Message
  ----     ------            ----                ----               -------
  Warning  FailedScheduling  26s (x18 over 24m)  default-scheduler  0/1 nodes are available: 1 node(s) had taints that the pod didn't tolerate.
```

To resolve it, execute this command

```
kubectl taint nodes --all node-role.kubernetes.io/master-
```


# Install Flannel as pod's virtual network

Setup an isolated virtual network where our pods and nodes can communicate with each other. We will be using flannel deployed as a pod inside Kubernetes as it is the most common virtual network setup used.

```
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/a70459be0084506e4ec919aa1c114638878db11b/Documentation/kube-flannel.yml
kubectl get pods,ds -n kube-system
```

### Install the dashboard

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/aio/deploy/recommended/kubernetes-dashboard.yaml
```

### How to log to dashboard without a password

See: https://stackoverflow.com/questions/46664104/how-to-sign-in-kubernetes-dashboard, https://docs.giantswarm.io/guides/install-kubernetes-dashboard/

Create a `ClusterRoleBinding` to grant the Dashboard `serviceaccount` the role `cluster-admin`

```bash
cat <<EOF | kubectl create -f -
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: kubernetes-dashboard
  labels:
    k8s-app: kubernetes-dashboard
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: kubernetes-dashboard
  namespace: kube-system
EOF
```
AND disable the authentication by adding the parameter `- --enable-skip-login` to the dashboard kubernetes deployment yaml resource within the container args section
```bash
kubectl edit deployment/kubernetes-dashboard --namespace=kube-system
...
spec:
  progressDeadlineSeconds: 600
  replicas: 1
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      k8s-app: kubernetes-dashboard
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      creationTimestamp: null
      labels:
        k8s-app: kubernetes-dashboard
    spec:
      containers:
      - args:
        - --auto-generate-certificates
        - --enable-skip-login
        image: k8s.gcr.io/kubernetes-dashboard-amd64:v1.10.1
```

### Start the proxy to access the dashboard remotely
```bash
kubectl proxy --address=192.168.99.50 --accept-hosts '.*'
```

### Setup ingress using helm

[See](https://kubernetes.github.io/ingress-nginx/deploy/)

Create first a `ClusterRoleBinding` for the `Tiller` serviceaccount

```bash
cat <<EOF | kubectl create -f - 
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: tiller-clusterrolebinding
subjects:
- kind: ServiceAccount
  name: tiller
  namespace: kube-system
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: ""
EOF
```
And now install helm

```bash
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get > get_helm.sh
chmod 700 get_helm.sh
./get_helm.sh
Downloading https://kubernetes-helm.storage.googleapis.com/helm-v2.13.1-linux-amd64.tar.gz
Preparing to install helm and tiller into /usr/local/bin
helm installed into /usr/local/bin/helm
tiller installed into /usr/local/bin/tiller
Run 'helm init' to configure helm.
```

Initialize helm client and Tiller server
```bash
helm init --service-account tiller
Creating /root/.helm
Creating /root/.helm/repository
Creating /root/.helm/repository/cache
Creating /root/.helm/repository/local
Creating /root/.helm/plugins
Creating /root/.helm/starters
Creating /root/.helm/cache/archive
Creating /root/.helm/repository/repositories.yaml
Adding stable repo with URL: https://kubernetes-charts.storage.googleapis.com
Adding local repo with URL: http://127.0.0.1:8879/charts
$HELM_HOME has been configured at /root/.helm.

Tiller (the Helm server-side component) has been installed into your Kubernetes Cluster.

Please note: by default, Tiller is deployed with an insecure 'allow unauthenticated users' policy.
To prevent this, run `helm init` with the --tiller-tls-verify flag.
For more information on securing your installation see: https://docs.helm.sh/using_helm/#securing-your-helm-installation
Happy Helming!
```

Install ingress using the helm chart
```bash
helm install stable/nginx-ingress --name my-nginx --set rbac.create=true
NAME:   my-nginx
LAST DEPLOYED: Tue Apr 16 07:51:06 2019
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/ConfigMap
NAME                               DATA  AGE
my-nginx-nginx-ingress-controller  1     1s

==> v1/Pod(related)
NAME                                                     READY  STATUS             RESTARTS  AGE
my-nginx-nginx-ingress-controller-5455d75d7f-qwkpk       0/1    ContainerCreating  0         1s
my-nginx-nginx-ingress-default-backend-5b8d7cb696-vvgfn  0/1    ContainerCreating  0         1s

==> v1/Service
NAME                                    TYPE          CLUSTER-IP      EXTERNAL-IP  PORT(S)                     AGE
my-nginx-nginx-ingress-controller       LoadBalancer  10.104.162.250  <pending>    80:30924/TCP,443:31742/TCP  1s
my-nginx-nginx-ingress-default-backend  ClusterIP     10.103.73.175   <none>       80/TCP                      1s

==> v1/ServiceAccount
NAME                    SECRETS  AGE
my-nginx-nginx-ingress  1        1s

==> v1beta1/ClusterRole
NAME                    AGE
my-nginx-nginx-ingress  1s

==> v1beta1/ClusterRoleBinding
NAME                    AGE
my-nginx-nginx-ingress  1s

==> v1beta1/Deployment
NAME                                    READY  UP-TO-DATE  AVAILABLE  AGE
my-nginx-nginx-ingress-controller       0/1    1           0          1s
my-nginx-nginx-ingress-default-backend  0/1    1           0          1s

==> v1beta1/Role
NAME                    AGE
my-nginx-nginx-ingress  1s

==> v1beta1/RoleBinding
NAME                    AGE
my-nginx-nginx-ingress  1s


NOTES:
The nginx-ingress controller has been installed.
It may take a few minutes for the LoadBalancer IP to be available.
You can watch the status by running 'kubectl --namespace default get services -o wide -w my-nginx-nginx-ingress-controller'

An example Ingress that makes use of the controller:

  apiVersion: extensions/v1beta1
  kind: Ingress
  metadata:
    annotations:
      kubernetes.io/ingress.class: nginx
    name: example
    namespace: foo
  spec:
    rules:
      - host: www.example.com
        http:
          paths:
            - backend:
                serviceName: exampleService
                servicePort: 80
              path: /
    # This section is only required if TLS is to be enabled for the Ingress
    tls:
        - hosts:
            - www.example.com
          secretName: example-tls

If TLS is enabled for the Ingress, a Secret containing the certificate and key must also be provided:

  apiVersion: v1
  kind: Secret
  metadata:
    name: example-tls
    namespace: foo
  data:
    tls.crt: <base64 encoded cert>
    tls.key: <base64 encoded key>
  type: kubernetes.io/tls
```

### Tear down

```
kubectl drain cloud --delete-local-data --force --ignore-daemonsets
kubectl delete node cloud
```
Then, on the node being removed, reset all kubeadm installed state:
```
kubeadm reset
```
