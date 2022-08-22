FROM golang:1.17

RUN go env -w GO111MODULE="on"

RUN go env -w GOPRIVATE="git.uino.com"

RUN go env -w GOSUMDB="off"

RUN go env -w GOPROXY="https://goproxy.cn,direct"

RUN git config --global url."https://thingyouwe:1AJzM-rYfRnug5Ls1ngz@git.uino.com/".insteadOf "https://git.uino.com/"

COPY ./entrypoint.sh /

COPY ./go-dep /

WORKDIR /go-dep

RUN go mod tidy

ENTRYPOINT /entrypoint.sh
