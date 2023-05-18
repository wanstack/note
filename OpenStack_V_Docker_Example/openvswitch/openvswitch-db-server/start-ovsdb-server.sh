#!/bin/bash

set -x

# NOTE(mnasiadka): ensure existing ovsdb doesn't need to be upgraded

mkdir -p "/run/openvswitch"
if [[ ! -e "/var/lib/openvswitch/conf.db" ]]; then
    ovsdb-tool create "/var/lib/openvswitch/conf.db"
fi

if ([ -f /var/lib/openvswitch/conf.db ] && [ `ovsdb-tool needs-conversion /var/lib/openvswitch/conf.db` == "yes" ]); then
  /usr/bin/ovsdb-tool convert /var/lib/openvswitch/conf.db
fi

ovsdb_ip=$1

/usr/sbin/ovsdb-server /var/lib/openvswitch/conf.db -vconsole:emer -vsyslog:err -vfile:info --remote=punix:/run/openvswitch/db.sock --remote=ptcp:6640:$ovsdb_ip --remote=db:Open_vSwitch,Open_vSwitch,manager_options --log-file=/var/log/cpcloud/openvswitch/ovsdb-server.log --pidfile
