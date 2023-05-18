#!/bin/bash

set -x
TAG=$1

docker rmi -f neutron-dhcp-agent:$TAG