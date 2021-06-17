# 使用ElastAlert实现日志告警

[官方网站](https://elastalert.readthedocs.io/en/latest/running_elastalert.html)

## 启动一个 ES 实例

```sh
docker run --rm --name es01-test --net elastic -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" docker.elastic.co/elasticsearch/elasticsearch:7.12.1
```

## 安装 ElastAlert

注意需要 Python 3.6以上版本

```sh
$ pip install elastalert
```

或者克隆仓库后手动安装

## 编写配置文件

可以去[代码仓库](https://github.com/Yelp/elastalert)下找到`config.yaml.example`文件，进行配置修改

下面选取主要的配置：
```yaml
# This is the folder that contains the rule yaml files
# Any .yaml file will be loaded as a rule
rules_folder: example_rules

# How often ElastAlert will query Elasticsearch
# The unit can be anything from weeks to seconds
run_every:
  minutes: 1

# ElastAlert will buffer results from the most recent
# period of time, in case some log sources are not in real time
buffer_time:
  minutes: 15

# The Elasticsearch hostname for metadata writeback
# Note that every rule can have its own Elasticsearch host
es_host: localhost

# The Elasticsearch port
es_port: 9200
```

## 向ES添加必要的索引

```sh
$ elastalert-create-index
```

## 创建一个告警规则

举例：
```sh
es_host: localhost
es_port: 9200
name: Example rule
type: frequency
index: test-alert-*
num_events: 1
timeframe:
    seconds: 2
filter:
- query:
    query_string:
      query: "level: ERROR"
alert:
- command
command: ["echo", "hello"]
```

## 打包镜像

```sh
# entrypoint.sh
#!/bin/sh

ls -al /etc/elastalert/rules

python3 -m elastalert.elastalert --verbose --config /etc/elastalert/config.yaml --rule /etc/elastalert/rules/*
```

```Dockerfile
FROM alpine:latest

RUN apk add --update gcc musl-dev python3-dev py3-pip libffi-dev openssl-dev cargo tzdata

RUN apk add --update python3

RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

RUN echo "Asia/Shanghai" > /etc/timezone

RUN date

RUN pip install elastalert

COPY ./entrypoint.sh /

ENTRYPOINT ["sh", "/entrypoint.sh"]
```

## 使用docker运行ElastAlert

- `config.yaml`

```yaml
# This is the folder that contains the rule yaml files
# Any .yaml file will be loaded as a rule
rules_folder: /rules

# How often ElastAlert will query Elasticsearch
# The unit can be anything from weeks to seconds
run_every:
  minutes: 1

# ElastAlert will buffer results from the most recent
# period of time, in case some log sources are not in real time
buffer_time:
  minutes: 15

# The Elasticsearch hostname for metadata writeback
# Note that every rule can have its own Elasticsearch host
es_host: log-es01

# The Elasticsearch port
es_port: 9200

use_ssl: true

ca_certs: /certs/ca.crt

es_username: elastic

es_password: Wb123@..

writeback_index: elastalert_status
```

- `thingyouwe-alertrule.yaml`

```yaml
es_host: log-es01
es_port: 9200
name: ThingyouweErrorLog
type: frequency
index: thingyouwe-*
num_events: 1
timeframe:
  minutes: 2
filter:
- query:
    query_string:
      query: "level: ERROR AND httpCode: 500"
alert: post
http_post_url: "http://your_ip:your_port/wechat-push/elastalert"
http_post_payload:
  level: level
  timestamp: "@timestamp"
  msg: msg
  id: _id
  env: K3S_ENV
  service: ServiceName
```

- docker run

```sh
docker run --rm --net elastic \
  -v `pwd`/config.yaml:/etc/elastalert/config.yaml \
  -v `pwd`/rules:/etc/elastalert/rules \
  dk.uino.cn/thingyouwe-base/alert:v1.0.0

docker run --rm --name es01-test \
  --net elastic \
  -p 9200:9200 -p 9300:9300 \
  -e "discovery.type=single-node" \
  docker.elastic.co/elasticsearch/elasticsearch:7.12.1
```

