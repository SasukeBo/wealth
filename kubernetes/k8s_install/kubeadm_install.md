# 安装 kubeadm

> 详细资料参考[官方文档](https://kubernetes.io/zh/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)

## 允许 iptables 检查桥接流量

> 为了让你的 Linux 节点上的 iptables 能够正确地查看桥接流量，你需要确保在你的 sysctl 配置中将 net.bridge.bridge-nf-call-iptables 设置为 1。例如：

```sh
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system
```

## 配置网络转发

部分服务器没有公网 IP，无法访问公网，需要使用 iptable 配置转发，必须是在有外网的那台服务器上指定

```sh
iptables -t nat -I POSTROUTING -s 172.16.9.0/24 -j SNAT --to-source 有公网的服务器内网地址
```

iptables -t nat -I POSTROUTING -s 172.16.9.117 -j SNAT --to-source 172.16.9.123

如果发现服务器配置后无法内网 ping 通，清除 iptables 规则 `iptables -F` 然后重启服务器

## 检查所需端口

### 控制平面节点

| 协议 | 方向 | 端口范围  |          作用           |            使用者            |
| :--: | :--: | :-------: | :---------------------: | :--------------------------: |
| TCP  | 入站 |   6443    |  Kubernetes API 服务器  |           所有组件           |
| TCP  | 入站 | 2379-2380 |  etcd 服务器客户端 API  |     kube-apiserver, etcd     |
| TCP  | 入站 |   10250   |       Kubelet API       |  kubelet 自身、控制平面组件  |
| TCP  | 入站 |   10251   |     kube-scheduler      |     kube-scheduler 自身      |
| TCP  | 入站 |   10252   | kube-controller-manager | kube-controller-manager 自身 |

### 工作节点

| 协议 | 方向 |  端口范围   |     作用      |           使用者           |
| :--: | :--: | :---------: | :-----------: | :------------------------: |
| TCP  | 入站 |    10250    |  Kubelet API  | kubelet 自身、控制平面组件 |
| TCP  | 入站 | 30000-32767 | NodePort 服务 |          所有组件          |

### 安装 kubeadm、kubelet 和 kubectl

- kubeadm：用来初始化集群的指令。
- kubelet：在集群中的每个节点上用来启动 Pod 和容器等。
- kubectl：用来与集群通信的命令行工具。

#### 基于 Red Hat 的发行版

先为 yum[配置阿里云镜像源](https://developer.aliyun.com/article/704987)

```sh
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

# 将 SELinux 设置为 permissive 模式（相当于将其禁用）
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

sudo systemctl enable --now kubelet
```

#### 基于 Debian 的发行版

1. 更新 apt 包索引并安装使用 Kubernetes apt 仓库所需要的包：

```sh
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
```

2. 下载 Google Cloud 公开签名秘钥：

```sh
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
```

3. 添加 Kubernetes apt 仓库：

```sh
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

4. 更新 apt 包索引，安装 kubelet、kubeadm 和 kubectl，并锁定其版本：

```sh
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

## 使用 kubeadm 创建高可用集群

### 初始化控制平面节点

> 控制平面节点是运行控制平面组件的机器， 包括 etcd （集群数据库） 和 API Server （命令行工具 kubectl 与之通信）。

由于官方镜像地址被墙，所以我们需要首先获取所需镜像以及它们的版本，然后从国内镜像站获取：

```sh
#!/bin/sh

images=`kubeadm config images list | sed 's/k8s\.gcr\.io\///' | tr " " "\n"`

for imageName in $images
do
  docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/$imageName
  docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/$imageName k8s.gcr.io/$imageName
  docker rmi registry.cn-hangzhou.aliyuncs.com/google_containers/$imageName
done;
```

对于部分拉取失败的镜像，也可以在本地翻墙拉取后再打包上传到服务器。

或者也可以替换 docker 的镜像源，如果你的 k8s 选择的容器技术是 docker：
修改文件 `/etc/docker/daemon.json`
添加镜像源：

```json
{
  "registry-mirrors": [
    "https://registry.cn-hangzhou.aliyuncs.com",
    "https://registry.docker-cn.com"
  ]
}
```

在 host 文件中配置:

```
your_ip_address kube-apiserver
```

等所有镜像文件准备就绪后执行安装命令：

```sh
sudo kubeadm init --control-plane-endpoint "LOAD_BALANCER_DNS:LOAD_BALANCER_PORT" --upload-certs
```

kubeadm init --control-plane-endpoint "k8s.vip:8443" --upload-certs

--upload-certs 标志用来将在所有控制平面实例之间的共享证书上传到集群。（比你自己管理要简单）

执行成功后会提示：

```
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

You can now join any number of control-plane nodes by copying certificate authorities
and service account keys on each node and then running the following as root:

  kubeadm join 172.16.9.123:6443 --token 3lsudh.f2t6g8t0i7ritdzj \
	--discovery-token-ca-cert-hash sha256:ab0f4a3a6d7f0d5aacca11a640e6db33824dfd64bbeacfb27327069d9ffdf6e5 \
	--control-plane

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 172.16.9.123:6443 --token 3lsudh.f2t6g8t0i7ritdzj \
	--discovery-token-ca-cert-hash sha256:ab0f4a3a6d7f0d5aacca11a640e6db33824dfd64bbeacfb27327069d9ffdf6e5
```

此时，集群的 master 节点已经安装完成了，可以执行：

```sh
kubectl get nodes
```

来查看节点状态。

我们按照提示来操作。

- 我们使用 root 权限运行，选择执行`export KUBECONFIG=/etc/kubernetes/admin.conf`来配置，将这段命令加入到你的 shell 启动配置文件中。
- 接下来需要安装 Pod 网络附加组件。
  选择使用 `weave`:

```sh
sysctl net.bridge.bridge-nf-call-iptables=1
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
```

## 其余控制平面节点的步骤

对于每个其他控制平面节点，你应该：

```sh
kubeadm join LOAD_BALANCER_DNS:LOAD_BALANCER_PORT --token token --discovery-token-ca-cert-hash sha256:7c2e69131a36ae2a042a339b33381c6d0d43887e2de83720eff5359e26aec866 --control-plane --certificate-key f8902e114ef118304e561c3ecd4d0b543adc226b7a07f675f56564185ffe0c07
```

add master
kubeadm join k8s.vip:8443 --token s0st1g.kb3g1ab4zact2xcn \
 --discovery-token-ca-cert-hash sha256:e9e681519c48da31e7ed8c7bcd52b6dcc4eccb24789867f9849c8b9c5fa6a45d \
 --control-plane

更多方式参考[链接](https://kubernetes.feisky.xyz/setup/cluster/kubeadm#pei-zhi-network-plugin)

sudo apt-get install docker-ce=$VERSION_STRING docker-ce-cli=$VERSION_STRING containerd.io

add worker
kubeadm join k8s.vip:8443 --token s0st1g.kb3g1ab4zact2xcn \
 --discovery-token-ca-cert-hash sha256:e9e681519c48da31e7ed8c7bcd52b6dcc4eccb24789867f9849c8b9c5fa6a45d

[weave-net pod fails to get peers](https://github.com/weaveworks/weave/issues/3420#issuecomment-431222618)
iptables -t nat -I KUBE-SERVICES -d 10.96.0.1/32 -p tcp -m comment --comment "default/kubernetes:https cluster IP" -m tcp --dport 443 -j KUBE-MARK-MASQ
