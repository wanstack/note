#!/bin/bash

set -x
TAG=$1

docker rmi -f neutron-l3-agent:$TAG