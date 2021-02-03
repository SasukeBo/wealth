# 备份与还原 Gitlab 实例

## 部署

推荐使用 docker 部署： `deploy.sh`

```sh
sudo docker run --detach \
  --hostname gitlab.sasuke.com \
  --publish 443:443 --publish 80:80 --publish 2224:22 \
  --env GITLAB_OMNIBUS_CONFIG="external_url 'http://gitlab.example.com/'; gitlab_rails['gitlab_shell_ssh_port'] = 2224" \
  --name gitlab \
  --restart always \
  --volume $GITLAB_HOME/config:/etc/gitlab \
  --volume $GITLAB_HOME/logs:/var/log/gitlab \
  --volume $GITLAB_HOME/data:/var/opt/gitlab \
  gitlab/gitlab-ce:latest
```

其中由于远程部署，22 端口被 ssh 占用，所以在容器外部映射需要换一个端口，例如`2224`

在部署之前需要指定`gitlab Docker`容器的数据挂载点，按照官网给出的`Ubuntu`环境的路径：

```sh
export GITLAB_HOME=/srv/gitlab
```

部署一个实例只需要：

```sh
./deploy.sh
```

## 备份

使用容器部署的`Gitlab`，备份十分方便：

```sh
sudo docker exec -t gitlab gitlab-backup create
```

执行成功后的备份文件在 `$GITLAB_HOME/data/backups`中，当你要转移你的`Gitlab`实例时，**该路径下的备份文件是最重要的**。
例：`1593690781_2020_07_02_13.1.2_gitlab_backup.tar`

**注意** 除了备份文件，配置文件和秘钥文件也是需要手动备份的，就如提示所言：

> Warning: Your `gitlab.rb` and `gitlab-secrets.json` files contain sensitive data
> and are not included in this backup. You will need these files to restore a backup.
> Please back them up manually.

也可见官方文档对此的[说明](https://docs.gitlab.com/ee/raketasks/backup_restore.html#storing-configuration-files)。

对于`Docker`容器部署的实例，这两个文件的位置在`$GITLAB_HOME/config`

_请将这些文件都妥善保管！_

## 恢复

使用容器部署的实例，在`Restore`时也是十分方便的。
但有个前提，需要你有一个新创建的`Gitlab`实例，不必要是容器，可以自行摸索。
先通过上面的脚本创建一个实例

```sh
./deploy.sh
```

等待容器启动完毕，可以查看容器日志来了解容器部署状态：

```sh
sudo docker logs -f gitlab
```

**注意** 一定要等容器部署完毕再执行`restore`，否则可能造成一些不可预知的错误，解决起来很麻烦。

容器部署完毕后将备份文件放入`$GITLAB_HOME/data/backups`，注意修改备份文件权限为 755。

```sh
sudo chmod -R 755 1593690781_2020_07_02_13.1.2_gitlab_backup.tar
```

接下来执行还原操作

```sh
sudo docker exec -it gitlab gitlab-backup restore
```

然后需要将之前手动备份的两个配置文件放入`$GITLAB_HOME/config`目录下。
进入容器实例：

```sh
sudo docker exec -it gitlab /bin/bash
```

最后重新执行以下指令来重新加载配置文件：

```sh
gitlab-ctl reconfigure
gitlab-ctl restart
```

## 最后

有问题自行 Google，建议先测试一遍，熟悉流程。

---

_最后编辑于 2021 年 01 月 27 日 11:32:21_

[返回目录](./menu.md)
