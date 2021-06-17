# 配置使用Kibana中的Alert功能

**注意** Elastic 的Alert要想支持邮件或者webhook等功能，需要花钱买证书。

## 为Elasticsearch设置安全性

### 最低的安全性

#### 启用Elasticsearch安全特性

- [Run in Docker with TLS enabled](https://www.elastic.co/guide/en/elastic-stack-get-started/7.13/get-started-docker.html#get-started-docker-tls)
为了启用es安全特性，必须要配置集群TLS，可以参考上面docker-compose的方案。

此处配置两个node：
```yml
# instances.yml
instances:
  - name: es01
    dns:
      - log-es01
      - localhost
    ip:
      - 127.0.0.1

  - name: es02
    dns:
      - log-es02
      - localhost
    ip:
      - 127.0.0.1

  - name: 'kib01'
    dns:
      - log-kibana
      - localhost
```
```sh
export VERSION=7.12.1
```
```yml
# create-certs.yml
version: '2.2'

services:
  create_certs:
    image: docker.elastic.co/elasticsearch/elasticsearch:${VERSION}
    container_name: create_certs
    command: >
      bash -c '
        yum install -y -q -e 0 unzip;
        if [[ ! -f /certs/bundle.zip ]]; then
          bin/elasticsearch-certutil cert --silent --pem --in config/certificates/instances.yml -out /certs/bundle.zip;
          unzip /certs/bundle.zip -d /certs;
        fi;
        chown -R 1000:0 /certs
      '
    working_dir: /usr/share/elasticsearch
    volumes:
      - ./certs:/certs
      - .:/usr/share/elasticsearch/config/certificates
    networks:
      - elastic

networks:
  elastic:
    driver: bridge
```

生成证书文件：
```sh
docker-compose -f create-certs.yml run --rm create_certs
```

- 将生成的证书文件通过rancher添加配置映射，配置到pod容器中去。

- 在 `elasticsearch.yml` 文件中配置：

  ```yml
  cluster.name: "docker-cluster"
  network.host: 0.0.0.0
  xpack.security.enabled: true
  xpack.security.http.ssl.enabled: true 
  xpack.security.http.ssl.key: certs/es.key
  xpack.security.http.ssl.certificate_authorities: certs/ca.crt
  xpack.security.http.ssl.certificate: certs/es.crt
  xpack.security.transport.ssl.enabled: true
  xpack.security.transport.ssl.verification_mode: certificate 
  xpack.security.transport.ssl.certificate_authorities: certs/ca.crt
  xpack.security.transport.ssl.certificate: certs/es.crt
  xpack.security.transport.ssl.key: certs/es.key
  xpack.license.self_generated.type: trial 
  ```

  如果是使用Docker运行的ES，其配置文件路径在容器内为`/usr/share/elasticsearch/config/`

#### 创建一个内置用户

一旦设置内置用户，所有来自ES外部的请求都必须经过认证。
- 启动ES
- 在ES中运行：

```sh
./bin/elasticsearch-setup-passwords auto
```

上述命令会自动生成密码，如果想设置自己的密码，执行：
```sh
./bin/elasticsearch-setup-passwords interactive
```
一旦为用户设置了密码，该命令则不能再使用。


#### 配置Kibana使用密码连接ES

Kibana 的配置文件在容器中的位置是`/usr/share/kibana/config/kibana.yml`

- 填写配置

```yml
server.name: kibana
server.host: "0"
elasticsearch.hosts: [ "http://elasticsearch:9200", "http://log-es01:9200" ]
elasticsearch.username: "kibana_system"

monitoring.ui.container.elasticsearch.enabled: true
```

- 创建Kibana keystore并且添加一些安全设置

```sh
kibana-keystore create
kibana-keystore add elasticsearch.password
```

- 重启 Kibana
- 登录并验证

  账号`elastic`
  密码为之前设置的密码

**注意** 由于ES启用了安全特性，所以logstash也需要配置ca.crt以及账号密码来写ES。

```conf
output {
    elasticsearch {
      hosts => ["https://log-es01:9200"]
			cacert => '/etc/logstash/config/certs/ca.crt'
			user => 'elastic'
			password => 'Wb123@..'
      index => "thingyouwe-%{[K3S_ENV]}-%{+YYYY.MM.dd}"
      codec => json
    }
}
```

## 配置Kibana

需要在kibana.yml文件中配置`xpack.encryptedSavedObjects.encryptionKey`

可以使用 `kibana-encryption-keys generate` 命令生成一个：

例如：
```yml
xpack.encryptedSavedObjects.encryptionKey: 214db5b4dee751f4affc319aae821d6e
xpack.reporting.encryptionKey: 3d5a13fb78fe66c70aa746be264a112d
xpack.security.encryptionKey: 61f938cd9cb8a1e6af1066da8dd30a68
```
