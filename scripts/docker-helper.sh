#!/bin/bash

echo "TIP: 当前运行的是docker帮助脚本，为了给容器带上当前用户名便于溯源"
echo "helloworld 会被更名为 helloworld_for_you"
echo "真正的docker二进制更名为docker_real"
echo ""

me=$(whoami)
args=($@)

case "$1" in

"run")

  name=""
  for i in "${!args[@]}"; do
    if [ "${args[i]}" == "--name" ]; then
      name="${args[i + 1]}"
      if [ "$name" != "" ]; then
        args[i + 1]="${name}_for_${me}"
      fi
    fi
  done

  if [ "$name" == "" ]; then
    image=${args[-1]}
    args[-1]="--name"
    rand=$(cat /proc/sys/kernel/random/uuid | md5sum | cut -c 1-9)
    args+=("${rand}_for_${me}")
    args+=("$image")
  fi

  # 给容器打上label
  image=${args[-1]}
  args[-1]="-l ${me}"
  args+=("$image")

  ;;

"ps")

  format="0"
  formatValueIndex=0
  for i in "${!args[@]}"; do
    if [ "${args[i]}" == "--format" ]; then
      formatValueIndex=$i+1
      format="${args[$i + 1]}"
      break
    fi
  done

  case $format in
  "1")
    args[$formatValueIndex]="table{{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
    ;;
  "2")
    args[$formatValueIndex]="table{{.Names}}\t{{.Image}}\t{{.Status}}\t{{.ID}}"
    ;;
  "3")
    args[$formatValueIndex]="table{{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Command}}"
    ;;
  "4")
    args[$formatValueIndex]="table{{.Names}}\t{{.Image}}\t{{.Status}}\t{{.CreatedAt}}"
    ;;
  "5")
    args[$formatValueIndex]="table{{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Mounts}}"
    ;;
  "5")
    args[$formatValueIndex]="table{{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Networks}}"
    ;;
  "all")
    args[$formatValueIndex]="table{{.ID}}\t{{.Image}}\t{{.Command}}\t{{.CreatedAt}}\t{{.Status}}\t{{.Ports}}\t{{.Names}}\t{{.Mounts}}\t{{.Networks}}"
    ;;

  *) ;;
  esac

  filterIndex=0
  for i in "${!args[@]}"; do
    if [ "${args[$i]}" == "-s" ]; then
      filterIndex=$i
      break
    fi
  done

  if [ $filterIndex != 0 ]; then
    args[$filterIndex]="--filter label=${me}"
  fi

  ;;
esac

echo "docker ${args[*]}"
echo ""
docker ${args[*]}
