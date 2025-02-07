#!/bin/bash

image=prom_feishutalk
tag=v1.0
dir_path="/root/docker-server/Prometheus-webhook-feishutalk"

function build(){
docker stop $(docker ps -a | grep $image | awk '{print $1}')
docker rm $(docker ps -a | grep $image | awk '{print $1}')
cd $dir_path
docker build -t $image:$tag .
docker run -d --name feishu_webhook -v /tmp:/tmp -p 5000:5000 $image:$tag
}

build
