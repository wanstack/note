#!/bin/bash

set -x


function start_service() {
    /usr/sbin/dnsmasq -k
    
}

function main() {
    start_service
}

main