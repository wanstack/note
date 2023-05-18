#!/bin/bash

set -x
TAG=$1

docker rmi -f placement:$TAG