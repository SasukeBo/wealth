# 为什么说 k8s 只有多租户

> Kubernetes 里网络隔离能力的定义：NetworkPolicy

NetworkPolicy 定义的规则，其实就是”白名单“。

```yml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: test-network-policy
  namespace: default
spec:
  podSelector:
    matchLabels:
      role: db
  policyTypes:
    - Ingress # 影响流入请求
    - Egress # 影响流出请求
  ingress:
    - from: # 允许访问的条件
        - ipBlock:
            cidr: 172.17.0.0/16 # 属于该网段可访问
            except:
              - 172.17.1.0/24 # 但不包括该子网段
        - namespaceSelector:
            matchLabels:
              project: myproject # 标签选择器，默认命名空间下的pod
        - podSelector:
            matchLabels:
              role: frontend # 标签选择
      ports:
        - protocol: TCP
          port: 6379
  egress:
    - to:
        - ipBlock:
            cidr: 10.0.0.0/24 # 仅允许对该网段发起向外请求
      ports: # 且 port必须是 5978
        - protocol: TCP
          port: 5978
```

注意上面文件中的`ingress.from`下的条件是`OR`关系，而要做到`AND`只需要改写为

```yml
ingress:
  - from:
      - namespaceSelector:
          matchLabels:
            user: alice
        podSelector: # 注意此处没有 '-'
          matchLabels:
            role: client
```

其实就是 yml 中的二维数组的表达方式

Kubernetes 网络插件对 Pod 进行隔离，其实是靠在宿主机上生成 NetworkPolicy 对应的 iptable 规则来实现的。
设置完隔离规则，网络插件还需要将请求转发到 KUBE-NWPLCY-CHAIN 上进行匹配。

---

_最后编辑于 2022 年 02 月 25 日 10:35:09_

[返回目录](./menu.md)
