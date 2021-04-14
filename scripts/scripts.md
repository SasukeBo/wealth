# Scripts

> 该文档记录一些常用的工具指令，便于复制

- v2ray v2-ui 一键部署

```sh
curl -Ls https://blog.sprov.xyz/v2-ui.sh | bash -
```

- ohmyzsh

```sh
# from github
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

- docker批量删除镜像，加过滤条件

```sh
# docker
docker rmi `docker images | grep dk.uino.cn/thingyouwe/ | awk '{print $3}'`
# k3s crictl
k3s crictl rmi `k3s crictl images | grep docker.udolphin.com | awk '{print $3}'`
```