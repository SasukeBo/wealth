# Go Micro 微服务开发环境搭建

## 私有仓库添加免登录

在自己的电脑下执行以下命令

```shell script
git config --global url."https://thingyouwe:Ru_-fP6fBBUCov-b4Nwa@git.uinnova.com/".insteadOf "https://git.uinnova.com/"
go env -w GO111MODULE="on"
go env -w GOPRIVATE="git.uinnova.com/thingyouwe"
go env -w GOSUMDB="off"
go env -w GOPROXY="https://goproxy.cn,direct"
```

这样就可以使用 thingyouwe group 下的代码仓库

## gRPC 开发依赖

- Protoc

```shell script
brew install protobuf
```

- 安装 protoc-gen-go

```shell script
go get -u github.com/golang/protobuf/protoc-gen-go@v1.3.4
```

- 安装 protoc-gen-micro 插件

```shell script
go get git.uinnova.com/thingyouwe-middleware/micro/cmd/protoc-gen-micro
```

- 检查安装状况

```shell script
cd $GOPATH/bin
ls | grep protoc
# =>
# protoc-gen-go
# protoc-gen-go-grpc
# protoc-gen-micro
```

---

_最后编辑于 2020 年 12 月 15 日 16:34:41_

[返回目录](./menu.md)
