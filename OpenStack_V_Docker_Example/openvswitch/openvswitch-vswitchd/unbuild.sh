#!/bin/bash

set -x
TAG=$1

docker rmi -f openvswitch-vswitchd:$TAG