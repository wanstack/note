#!/bin/bash

src_dir=$1
if test -z "$src_dir"; then
    echo "usage: $0 <image source dir>"
    exit 1
fi

. /root/admin.openrc

dbuser=glance
dbpass=$(crudini --get /etc/glance/glance-api.conf database connection | sed 's/^.*glance:\(.*\)@.*$/\1/')

find "$src_dir" -name disk -o -name "*.qcow2" -o -name "*.raw" -o -name "*.vmdk" -o -name "*.tar" | while read disk_file; do

    # Skip directories with. Qcow2,. Raw,. VMDK, and. Tar names
    if test -d "$disk_file" ; then
        continue
    fi

    dir="$(dirname "$disk_file")"
    name="$(basename "$(realpath "$dir")")"

    sed -i 's/\r//g' "$dir"/info
    . "$dir"/info

    if [[ "$container_format" == "docker" ]]; then
        name=${name//:/_}
    fi

    n=$(echo "select count(1) from images where name='$name' and deleted=0" | mysql -N -u$dbuser -p$dbpass -hcontroller glance)
    if [ $n -gt 0 ]; then
        echo "image $name exists"
        continue
    fi

    echo "importing $name"

    if ! [ -e "$dir"/info ]; then
        echo "ERROR: missing files in $dir"
        continue
    fi

    props=$(awk '/^os_/||/^hw_/{print "--property", $0}' "$dir"/info)

    eval cpc image create \
        --container-format $container_format \
        --disk-format $disk_format \
        --min-disk $min_disk --min-ram $min_ram \
        --file "$disk_file" --private $props "$name"
done
