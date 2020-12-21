# 搭建 k3s

k3s —— 史上最轻量级 Kubernetes，易于安装，只需 512MB RAM 即可运行。

[k3s 文档](https://docs.rancher.cn/k3s/)

**本教程基于 centos 7.8 64 位环境**

## 搭建步骤

### 服务器搭建前的配置

1. 修改 host 名称

通过执行下面的指令将服务器 hostname 设置为 k8s-master：

```shell
hostnamectl set-hostname k8s-master
```

你可以通过执行下面的指令检查是否设置成功

```shell
hostname
#=> k8s-master
```

之后会在上面搭建 k8s master 主节点，相应的，在需要搭建 k8s worker 节点的服务器上设置好 hostname，
另外，如果你要搭建多个 master/worker 节点，可以在后面加上序号，例如：`k8s-master-1`。

2. 修改 hosts 文件

为了方便在内网直接识别各服务器，可以在 hosts 文件中添加映射：

```shell
cat <<EOF >>/etc/hosts
172.17.0.12 k8s-master
172.10.0.15 k8s-worker-1
172.10.0.18 k8s-worker-2
EOF
```

请将上面 ip 修改为您的服务器对应的内网 ip。

3. 配置防火墙

执行如下所有指令来配置防火墙：

```shell
systemctl stop firewalld
systemctl disable firewalld
setenforce 0
sed -i "s/^SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config
swapoff -a
sed -i 's/.*swap.*/#&/' /etc/fstab
```

4. 配置内核参数

将桥接的 IPv4 流量传递到 iptables 的链：

```shell
cat > /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sysctl --system
```

### 准备 k3s 运行需要的数据库

1. 安装 docker

如果你是 centos 环境，可以通过 yum 直接安装

```shell
yum install docker
```

其他系统请参照[官网教程](https://docs.docker.com/engine/install/)

2. 使用 docker 部署 mysql

```shell
docker run -p 3306:3306 --name mysql \
-v /home/mysql/conf:/etc/mysql \
-v /home/mysql/logs:/var/log/mysql \
-v /home/mysql/data:/var/lib/mysql \
-e MYSQL_ROOT_PASSWORD=your_root_password \
-d mysql:5.7
```

如上指令创建了一个 mysql 容器，将 3306 端口映射到宿主机，并且将容器内的 mysql 数据存储目录挂载到宿主机，root 账号的密码为`your_root_password`，请自行修改为你需要的密码。mysql 版本为 5.7.x

3. 创建数据库

首先需要进入 mysql 容器环境：

```shell
docker exec -it mysql /bin/bash
```

然后使用`mysql`命令行客户端连接数据库：

```shell
mysql -u root -p
```

输入密码后，进入交互，创建一个数据库作为 k3s 的数据存储数据库，这里取名为`k8s_db`：

```sql
CREATE DATABASE k8s_db;
```

### 安装 master 节点

这里使用的是[官方文档脚本](https://docs.rancher.cn/docs/k3s/quick-start/_index)：

```shell
curl -sfL http://rancher-mirror.cnrancher.com/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn sh -s - server \
  --datastore-endpoint="mysql://root:your_root_password@tcp(k8s-master:3306)/k8s_db"
```

需要将`datastore-endpoint`中的信息修改为前面部署的 mysql 数据库信息，这里修改为`mysql://root:your_root_password@tcp(k8s-master:3306)/k8s_db`。

通过执行下面到命令来检查是否部署成功：

```shell
kubectl get nodes
#=> NAME         STATUS   ROLES    AGE   VERSION
#=> k3s-master   Ready    master   8h    v1.19.5+k3s1
```

**注意**

如果你要跨公网部署集群，需要暴露节点的公网 ip，启动时记得加上 `--node-external-ip=<public_ip>`

### 安装 worker 节点

这里使用的是[官方文档脚本](https://docs.rancher.cn/docs/k3s/quick-start/_index)：

```shell
curl -sfL http://rancher-mirror.cnrancher.com/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn K3S_URL=https://k8s-master:6443 K3S_TOKEN=$node_token sh -
```

其中需要替换两个地方：

- `K3S_URL`，该参数指定了 master 节点服务的位置，这里修改为`https://k8s-master:6443`
- `K3S_TOKEN`，该参数需要指定 master 节点的 node_token，其文件存储路径为`/var/lib/rancher/k3s/server/node-token`

```shell
cat /var/lib/rancher/k3s/server/node-token
#=> K10c00f954cf3b229eadc05c942f55fa962893bdcc4ab48faa023f54424276e10e0::server:91d449553527b80bde9e5b9deb187db4
```

同样通过在 master 节点宿主机上执行`kubectl get nodes`来检查 worker 节点是否成功加入了集群。

### 使用 docker 搭建 rancher

rancher 用于可视化管理你的 k8s 集群。

```shell
sudo docker run -d --restart=unless-stopped --privileged --name rancher -p 30080:80 -p 30443:443 rancher/rancher
```

由于我们的 rancher 是搭建在 master 节点宿主机上，所以要让出 80 和 443 端口，当然你也可以选择在另一台服务器上部署 rancher，就可以使用 80 和 443 端口来访问 rancher 界面。

恭喜，到这里，该安装的都安装完了。

**Tips**

- 卸载 k3s agent `/usr/local/bin/k3s-agent-uninstall.sh`
- 卸载 k3s server `/usr/local/bin/k3s-uninstall.sh`

---

_最后编辑于 2020 年 12 月 17 日 20:31:01_

[返回目录](./menu.md)
