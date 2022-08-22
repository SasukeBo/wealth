#!/bin/bash

cd /app
go mod tidy
APOLLO_IP=apollo.api.thingyouwe.com go run main.go
