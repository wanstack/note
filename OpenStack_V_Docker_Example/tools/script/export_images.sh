#!/bin/bash

if test "$1" = "-s"; then
    is_sub_process=true
    shift
else
    is_sub_process=false
fi

exe_dir=$(dirname $0)
images=$1
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
    datadir=$(crudini --get /etc/glance/glance-api.conf glance_store filesystem_store_datadir)
    datadir=${datadir/%\//} # remove the / suffix
    dbuser=glance
    dbpass=$(crudini --get /etc/glance/glance-api.conf database connection | sed 's/^.*glance:\(.*\)@.*$/\1/')
    default_store=$(crudini --get /etc/glance/glance-api.conf glance_store default_store)
}

export_image(){
    image=$1

    if [[ "$image" =~ [0-9a-f]*-[0-9a-f]*-[0-9a-f]*-[0-9a-f]*-[0-9a-f]* ]]; then
        image_id=$image
        image_name=$(mysql -N -u$dbuser -p$dbpass -hcontroller glance <<<"select name from images where deleted=0 and id='$image_id'")
    else
        image_name=$image
        image_id=$(mysql -N -u$dbuser -p$dbpass -hcontroller glance <<<"select id from images where deleted=0 and name='$image'")
        if test $(echo "$image_id" | wc -w) -gt 1; then
            echo "WARNING: image name $name is ambiguous, choosing the latest"
            image_id=$(mysql -N -u$dbuser -p$dbpass -hcontroller glance <<<"select id from images where deleted=0 and name='$image_name' order by created_at desc limit 1")
        fi
    fi
    if test -z "$image_id"; then
        echo "ERROR: image $image not found"
        return 1
    fi

    echo "exporting image '$image_name' $image_id"

    subdir=$out_dir/$image_name
    test -e "$subdir" || mkdir -p "$subdir"
    if [ -e "$subdir/disk" ]; then
        echo "INFO: $subdir/disk already exists"
        return 0
    fi

    echo \
      "select concat('container_format=',quote(container_format)) from images where id = '$image_id';"\
      "select concat('disk_format=',quote(disk_format)) from images where id = '$image_id';"\
      "select concat('min_disk=',quote(min_disk)) from images where id = '$image_id';"\
      "select concat('min_ram=',quote(min_ram)) from images where id = '$image_id';"\
      "select concat(name,'=',quote(value)) from image_properties "\
      "where image_id = '$image_id' and deleted=0 "\
      " and (name like 'hw_%' or name like 'os_%');"\
      | mysql -N -u$dbuser -p$dbpass -hcontroller glance >> "$subdir"/info

    snapshot_id=$(echo "select value from image_properties where image_id = '$image_id' and name = 'block_device_mapping'" |
        mysql -N -u$dbuser -p$dbpass -hcontroller glance | sed 's/.*snapshot_id": "\([a-z0-9-]*\)".*$/\1/')
    if test -n "$snapshot_id"; then
        if ! $exe_dir/export_snapshots.sh -s -m $snapshot_id "$subdir"; then
            echo "ERROR: failed to export snapshot for image $image"
            return 1
        else
            return 0
        fi
    fi
        
    if [ "$default_store" = file ]; then
        /bin/cp -av --sparse=always "$datadir/$image_id" "$subdir"/disk.tmp
        /bin/mv "$subdir"/disk.tmp "$subdir"/disk
    elif [ "$default_store" = rbd ]; then
        rbd --id cpc export images/$image_id "$subdir"/disk.tmp
        /bin/mv "$subdir"/disk.tmp "$subdir"/disk
    fi
    return 0
}

main(){
    init_vars

    if [[ "$images" != --all && ("$images" =~ [0-9a-f]*-[0-9a-f]*-[0-9a-f]*-[0-9a-f]*-[0-9a-f]* || ! -f "$images") ]]; then
        export_image "$images"
        exit
    fi

    images_file_tmp=$(mktemp /tmp/images_XXXX)
    if [ "$images" == --all ]; then
        mysql -N -u$dbuser -p$dbpass -hcontroller glance <<<"select name from images where deleted=0" > $images_file_tmp
        images_file=$images_file_tmp
    else
        images_file="$images"
    fi

    failed=$(mktemp /tmp/failed_XXXX)

    while read image; do
        test -z "$image" && continue
        if ! export_image "$image"; then
            echo "$image" >> $failed
        fi
    done < $images_file

    if test -s $failed; then
        if ! $is_sub_process; then
            echo "failed to export the following: "
            cat $failed
        fi
        ret=1
    fi

    /bin/rm $failed
    /bin/rm $images_file_tmp
    exit $ret
}

main

