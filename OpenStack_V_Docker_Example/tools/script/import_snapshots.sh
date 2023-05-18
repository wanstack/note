#!/bin/bash

src_dir=$1
if test -z "$src_dir"; then
    echo "usage: $0 <snapshot source dir>"
    exit 1
fi

if ! test -d "$src_dir"; then
    echo "ERROR: source dir $src_dir not exist"
    exit 1
fi

. /root/admin.openrc

dbuser=cinder
dbpass=$(crudini --get /etc/cinder/cinder.conf database connection | sed 's/^.*cinder:\(.*\)@.*$/\1/')
enabled_backends=$(crudini --get /etc/cinder/cinder.conf DEFAULT enabled_backends)

chown cinder:cinder /var/lib/cinder/mnt/*

find "$src_dir" -name disk -o -name "*.qcow2" -o -name "*.vmdk" -o -name "*.raw" | while read disk_file; do

    # Skip directories with. Qcow2,. Raw,. VMDK, and. Tar names
    if test -d "$disk_file" ; then
        continue
    fi

    dir="$(dirname "$disk_file")"
    name="$(basename "$(realpath "$dir")")"

    n=$(echo "select count(1) from snapshots where display_name='$name' and deleted=0" | mysql -N -u$dbuser -p$dbpass -hcontroller cinder)
    if [ $n -gt 0 ]; then
        echo "snapshort $name exists"
        continue
    fi

    echo "importing $name"

    if ! [ -e "$dir"/info ]; then
        echo "ERROR: missing files in $dir"
        continue
    fi

    sed -i 's/\r//g' "$dir"/info
    . "$dir"/info

    virtual_size_bytes=$(qemu-img info "$disk_file" | awk '/virtual size/{print substr($5,2,length($5)-1)}')
    file_format=$(qemu-img info "$disk_file" | awk '/file format/{print $3}')
    virtual_size_gb=$(python -c "import math; print(int(math.ceil($virtual_size_bytes/1024./1024/1024)))")
    if test -z "$virtual_size_gb"; then
        echo "ERROR: failed to get virtual size"
        continue
    fi
    if [ $virtual_size_gb -eq 0 ];then
        echo "ERROR: Get virtual_size_gb is 0, Please check the '$disk_file'"
        exit 1
    fi
    if test $virtual_size_gb -lt "$min_disk"; then
        virtual_size_gb=$min_disk
    fi

    showmount -e controller > /dev/null
    if [ $? != 0 ] ; then
         echo "[ERROR] nfs service start failed";
         systemctl restart  nfs-server ; sleep 10
    fi

    volume_id=$(cpc volume create -f value -c id --size $virtual_size_gb --bootable "vol-$name")
    volume_id=`eval echo $volume_id`

    if [ x"$volume_id" = x ] ; then
      echo "[ERROR] cpc volume create -f value -c id --size $virtual_size_gb --bootable vol-$name Failed ;Please check /var/log/cinder logs!"; exit 1
    else
      echo "cpc volume create -f value -c id --size $virtual_size_gb --bootable  vol-$name ..."
      while true; do
        status=$(cpc volume show -f value -c status $volume_id)
        if [ "$status" = available ]; then
            break
        else
            echo "$status"
        fi
      done
    fi

    props=$(awk '{print "--image-property", $0}' "$dir"/info)
    if [ -n "$props" ]; then
        eval cpc volume set $props $volume_id
        eval cpc volume set --image-property disk_format='qcow2' $volume_id
    fi

    if [ "$enabled_backends" = "nfs" ]; then
        n=$(ls /var/lib/cinder/mnt/*/volume-${volume_id} | wc -l)
        if [ $n = 0 ]; then
            echo "ERROR: volume file not found for $volume_id"
            continue
        elif [ $n -gt 1 ]; then
            echo "ERROR: more than 1 volume files found for $volume_id"
            continue
        fi
        volume_file=$(ls /var/lib/cinder/mnt/*/volume-${volume_id})

        tmp=${volume_file}.tmp
        umask a+rw
        if [ "$file_format" = "qcow2" ]; then
            /bin/cp -v --sparse=always "$disk_file" "$tmp"
        else
            echo "converting file format to qcow2"
            qemu-img convert -f "$file_format" -O qcow2 "$disk_file" "$tmp"
        fi
        chown cinder:cinder "$tmp"
        /bin/mv "$tmp" "$volume_file"
    elif [ "$enabled_backends" = "rbd" ]; then
        qemu-img convert -O rbd "$disk_file" rbd:volumes/volume-${volume_id}.tmp:id=openstack
        rbd --id cpc rm volumes/volume-${volume_id}
        rbd --id cpc mv volumes/volume-${volume_id}.tmp volumes/volume-${volume_id}
    fi

    cpc volume snapshot create --volume $volume_id "$name"
done
