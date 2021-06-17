## start message-srv
docker run \
    --name message-srv \
    -v $PWD/main:/app \
    --network thingyouwe-local \
    -p 80:80 \
    -e APOLLO_IP=apollo.api.thingyouwe.com \
    -e APOLLO_ENV=wb_local \
    -e APOLLO_APPID=message-srv \
    -e registry=etcd \
    golang:1.16 /app

## start user_v2-center-srv
docker run \
    --name user_v2-center-srv \
    -v $PWD/main:/app \
    --network thingyouwe-local \
    -e APOLLO_IP=apollo.api.thingyouwe.com \
    -e APOLLO_ENV=wb_local \
    -e APOLLO_APPID=user_v2-center-srv \
    -e registry=etcd \
    golang:1.16 /app

## start im-store-srv
docker run \
    --name im-store-srv \
    -v $PWD/main:/app \
    --network thingyouwe-local \
    -e APOLLO_IP=apollo.api.thingyouwe.com \
    -e APOLLO_ENV=local \
    -e APOLLO_APPID=im-store-srv \
    -e registry=etcd \
    golang:1.16 /app

docker run \
    --name ws-srv \
    -v $PWD/main:/app \
    --network thingyouwe-local \
    -e APOLLO_IP=apollo.api.thingyouwe.com \
    -e APOLLO_ENV=wb_local \
    -e APOLLO_APPID=ws-srv \
    -e registry=etcd \
    golang:1.16 /app

docker run -d \
    --name uuid-srv \
    -v $PWD/main:/app \
    --network thingyouwe-local \
    -e APOLLO_IP=apollo.api.thingyouwe.com \
    -e APOLLO_ENV=wb_local \
    -e APOLLO_APPID=uuid-srv \
    -e registry=etcd \
    golang:1.16 /app