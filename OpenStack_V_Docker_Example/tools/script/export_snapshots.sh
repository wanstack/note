#!/bin/bash

if test "$1" = "-s"; then
    is_sub_process=true
    shift
else
    is_sub_process=false
fi

if test "$1" = "-m"; then
    make_dir=false
    shift
else
    make_dir=true
fi

snapshots=$1
out_dir=$2
if test -z "$out_dir"; then
    echo "Examples: "
    echo "    $0 images.txt /mnt/backup"
    echo "    $0 --all /mnt/backup"
    echo "    $0 centos7 /mnt/backup"
    echo "    $0 d0a5cde2-869d-4f42-89c8-c7ddd12f7a83 /mnt/backup"
    exit 1
fi

init_vars(){
    . /root/admin.openrc

    dbuser=cinder
    dbpass=$(crudini --get /etc/cinder/cinder.conf database connection | sed 's/^.*cinder:\(.*\)@.*$/\1/')

    enabled_backends=$(crudini --get /etc/cinder/cinder.conf DEFAULT enabled_backends)
}

export_snapshot(){
    snapshot=$1

    if [[ "$snapshot" =~ [0-9a-f]*-[0-9a-f]*-[0-9a-f]*-[0-9a-f]*-[0-9a-f]* ]]; then
        snapshot_id=$snapshot
        snapshot_name=$(mysql -N -u$dbuser -p$dbpass -hcontroller cinder <<<"select display_name from snapshots where deleted=0 and id='$snapshot_id'")
    else
        snapshot_name=$snapshot
        snapshot_id=$(mysql -N -u$dbuser -p$dbpass -hcontroller cinder <<<"select id from snapshots where deleted=0 and display_name='$snapshot'")
        if test $(echo "$snapshot_id" | wc -w) -gt 1; then
            echo "WARNING: snapshot name $snapshot is ambiguous, choosing the latest"
            snapshot_id=$(mysql -N -u$dbuser -p$dbpass -hcontroller cinder <<<"select id from snapshots where deleted=0 and display_name='$snapshot' order by created_at desc limit 1")
        fi
    fi
    if test -z "$snapshot_id"; then
        echo "ERROR: snapshot $snapshot not found"
        return 1
    fi
    echo "exporting snapshot '$snapshot_name' $snapshot_id"

    # check volume files
    volume_id=$(mysql -N -u$dbuser -p$dbpass -hcontroller cinder <<<"select volume_id from snapshots where deleted=0 and id='$snapshot_id'")
    if test -z "$volume_id"; then
        echo "ERROR: snapshot $snapshot not found"
        return 1
    fi

    if ! $make_dir; then
        subdir=$out_dir
    else
        subdir="$out_dir/$snapshot_name"
        test -e "$subdir" || mkdir -p "$subdir"
    fi

    if [ -e "$subdir"/disk ]; then
        echo "INFO: "$subdir"/disk already exists"
        return 0
    fi

    if [ ! -s "$subdir"/info ]; then
        echo "select concat(\`key\`,'=',quote(value)) from volume_glance_metadata "\
             "where volume_id = '$volume_id' and deleted=0 "\
             "and (\`key\` in ('min_disk', 'min_ram', 'container_format', 'disk_format') or \`key\` like 'os_%' or \`key\` like 'hw_%')"\
           | mysql -N -u$dbuser -p$dbpass -hcontroller cinder > "$subdir"/info
    fi

    if [ "$enabled_backends" = nfs ]; then
        n=$(ls /var/lib/cinder/mnt/*/volume-${volume_id}.${snapshot_id} | wc -l)
        if [ $n = 0 ]; then
            echo "ERROR: snapshot file $snapshot_file not found"
            return 1
        elif [ $n -gt 1 ]; then
            echo "ERROR: more than 1 snapshot files found for ${snapshot_id}"
            return 1
        fi
        snapshot_file=$(ls /var/lib/cinder/mnt/*/volume-${volume_id}.${snapshot_id})
        if ! qemu-img check -q "$snapshot_file"; then
            echo "ERROR: failed to check $snapshot_file" 
            return 1
        fi
        bk=$(qemu-img info "$snapshot_file" | grep 'backing file:' | sed 's/^.*actual path: \(.*\))/\1/')
        qemu-img convert -O qcow2 "$bk" "$subdir"/disk.tmp
        /bin/mv "$subdir"/disk.tmp "$subdir"/disk
    elif [ "$enabled_backends" = rbd ]; then
        rbd --id openstack export --snap snapshot-$snapshot_id volumes/volume-$volume_id "$subdir"/disk.tmp
        /bin/mv "$subdir"/disk.tmp "$subdir"/disk
    fi

    return 0
}

main(){
    init_vars

    if [[ "$snapshots" != --all && ("$snapshots" =~ [0-9a-f]*-[0-9a-f]*-[0-9a-f]*-[0-9a-f]*-[0-9a-f]* || ! -f "$snapshots") ]]; then
        export_snapshot "$snapshots"
        exit
    fi

    snapshots_file_tmp=$(mktemp /tmp/snapshots_XXXX)
    if [ "$snapshots" == --all ]; then
        mysql -N -u$dbuser -p$dbpass -hcontroller cinder <<<"select id from snapshots where deleted=0 and display_name not like '%的快照' and display_name not like 'snapshot for %'" > $snapshots_file_tmp
        snapshots_file=$snapshots_file_tmp
    else
        snapshots_file="$snapshots"
    fi

    failed=$(mktemp /tmp/failed_XXXX)

    while read snapshot; do
        test -z "$snapshot" && continue
        if ! export_snapshot "$snapshot"; then
            echo "$snapshot" >> $failed
        fi
    done < $snapshots_file

    if test -s $failed; then
        if ! $is_sub_process; then
            echo "failed to export the following: "
            cat $failed
        fi
        ret=1
    fi

    /bin/rm $failed
    /bin/rm $snapshots_file_tmp
    exit $ret
}

main
