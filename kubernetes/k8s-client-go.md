# 使用 kubernetes client-go 管理集群

> 该文档介绍如何使用 k8s go 客户端管理集群，本教程的 k8s 集群是使用 k3s 搭建的，请注意该教程是否适用于你的版本

## 场景

为了解决在 gitlab-ci 流水线中自动部署服务至 k8s 集群的问题，需要调用 k8s api，起初想到的解决方案是通过 curl 发起 http 请求调用 k8s RESTFul api，但是这种方式请求体必须是 application/json 格式，由于部署文件中会用到很多环境变量，不得不将部署文件转为 json 字符串表现在 shell 脚本中，这种方式阅读性很差，并且修改配置很难。
类似如下：

```sh
curl "https://118.31.172.31:6443/apis/apps/v1/namespaces/thingyouwe-${CI_COMMIT_REF_NAME}/deployments/${CI_PROJECT_NAME}" \
-X 'PUT' \
-H "Authorization: Bearer ${K8S_SECRET_TOKEN}" \
-H 'content-type: application/json' \
-d "{ \"apiVersion\": \"apps/v1\", \"kind\": \"Deployment\", \"metadata\": { \"name\": \"${CI_PROJECT_NAME}\", \"namespace\": \"thingyouwe-${CI_COMMIT_REF_NAME}\", \"labels\": { \"app\": \"${CI_PROJECT_NAME}\" } }, \"spec\": { \"replicas\": 1, \"selector\": { \"matchLabels\": { \"app\": \"${CI_PROJECT_NAME}\" } }, \"template\": { \"metadata\": { \"labels\": { \"app\": \"${CI_PROJECT_NAME}\" } }, \"spec\": { \"serviceAccountName\": \"micro-services\", \"imagePullSecrets\": [ { \"name\": \"pipeline-bj-registry1\" } ], \"containers\": [ { \"name\": \"${CI_PROJECT_NAME}\", \"image\": \"docker.udolphin.com/thingyouwe/${CI_PROJECT_NAME}:${CI_COMMIT_SHA}\", \"ports\": [ { \"containerPort\": 80 } ], \"env\": [ { \"name\": \"APOLLO_IP\", \"value\": \"apollo.api.test.thingyouwe.com\" }, { \"name\": \"APOLLO_ENV\", \"value\": \"${CI_COMMIT_REF_NAME}\" }, { \"name\": \"APOLLO_APPID\", \"value\": \"${APOLLO_APPID}\" } ] } ] } } } }" \
  --insecure -i
```

且每次请求只能操作一种资源，局限性很大。所以寻求更好的方案。

## 前提

> 在一个安全的内网环境中，k8s 的各个组件与 master 之间可以通过 kube-apiserver 的非安全端口`http://<internal-ip>:8080`进行访问，但如果 API server 需要对外提供服务，或者集群中的某些容器也需要访问 API server 以获取集群中的某些信息，则需要采取更安全的 HTTPS 安全机制。

我们分析一下 client-go 项目中的例子：

```go
// in examples/out-of-cluster-client-configuration/main.go

var kubeconfig *string
if home := homedir.HomeDir(); home != "" {
	kubeconfig = flag.String("kubeconfig", filepath.Join(home, ".kube", "config"), "(optional) absolute path to the kubeconfig file")
} else {
	kubeconfig = flag.String("kubeconfig", "", "absolute path to the kubeconfig file")
}
flag.Parse()

// use the current context in kubeconfig
config, err := clientcmd.BuildConfigFromFlags("", *kubeconfig)
```

该示例中配置了参数`kubeconfig`用于指定客户端连接`apiserver`时需要用到的配置，这个配置文件长这样：

```yaml
apiVersion: v1
clusters:
  - cluster:
      server: https://k8s-server-ip:6444
      certificate-authority: server-ca.crt
    name: local
contexts:
  - context:
      cluster: local
      namespace: default
      user: user
    name: Default
current-context: Default
kind: Config
preferences: {}
users:
  - name: user
    user:
      client-certificate: client-kube-apiserver.crt
      client-key: client-kube-apiserver.key
```

如果不指定客户端的 ca 配置，apiserver 是会拒绝访问的：

```sh
$ go run main.go
panic: Get "https://k8s-server-ip:6444/api/v1/pods": x509: certificate signed by unknown authority
```

要想在外网环境下安全调用 api，正常来说需要：

- 为 kube-apiserver 生成：ca.crt、ca.key、ca.srl、server.crt、server.csr 和 server.key
- 为账号生成客户端证书和私钥。
  由于 k3s 已经为一些账号生成了客户端私钥和证书，我就没有尝试自己去生成，想要自己生成可以参考[官方教程](https://kubernetes.io/zh/docs/reference/access-authn-authz/authentication/)。

## 获取客户端证书和私钥

k3s 生成的证书秘钥在该目录下：
`/var/lib/rancher/k3s/server/cred`

```sh
ls -al
drwx------ 2 root root 4096 2月   3 14:43 .
drwx------ 7 root root 4096 1月  27 00:10 ..
-rw-r--r-- 1 root root  472 1月  27 00:08 admin.kubeconfig
-rw-r--r-- 1 root root  490 1月  27 00:08 api-server.kubeconfig
-rw-r--r-- 1 root root  494 1月  27 00:08 cloud-controller.kubeconfig
-rw-r--r-- 1 root root  482 1月  27 00:08 controller.kubeconfig
-rw------- 1 root root   97 1月  27 00:08 ipsec.psk
-rw------- 1 root root  111 1月  27 00:08 passwd
-rw-r--r-- 1 root root  480 1月  27 00:08 scheduler.kubeconfig
```

根据所需权限，可以将对应的配置文件拷贝出来，并且将配置文件中的证书和秘钥也拷贝出来，修改好路径及 ip 端口号，就可以使用对应账号的权限来访问 api-server 了。

**注意**
这种方式只是偷懒的方式，实际上应该为自己业务需求创建对应的账号，并为其生成对应的客户端秘钥和证书。

---

_2021 年 02 月 03 日 15:37:23_

[返回目录](./menu.md)
