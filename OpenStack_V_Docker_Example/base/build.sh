#!/bin/bash

WORKDIR=$(cd $(dirname $0); pwd)

docker build -t openstack-base $WORKDIR