# 通过 Docker 安装 Rancher v2.6 并使用自己的证书

## 生成证书

这里使用 OpenSSL，参考资料：[链接](https://www.feistyduck.com/library/openssl-cookbook/online/ch-openssl.html)

按照资料里说的，大多数人使用 OpenSSL 是为了生成证书。

### 生成 Key 文件

使用 genpkey 命令，这里选择的算法是 RSA，Key 大小为 2048 被视作是安全大小。

```sh
./create_self-signed-cert.sh --ssl-domain=rancher.thingyouwe.com \
 --ssl-trusted-ip=0.0.0.0,172.16.9.125,121.196.15.61 --ssl-size=2048 --ssl-date=36500
```
