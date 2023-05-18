#!/bin/bash

set -x
TAG=$1

docker rmi -f neutron-openvswitch-agent:$TAG