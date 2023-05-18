#!/bin/bash

set -x

source /etc/environment_config.conf
source /etc/admin.openrc

test -d /var/log/cpcloud/nginx || mkdir -p /var/log/cpcloud/nginx

function install_nginx() {
      cat << EOF > /etc/nginx/nginx.conf
#user nginx;
user root;
worker_processes auto;
error_log /var/log/cpcloud/nginx/error.log;
pid /run/nginx.pid;
include /usr/share/nginx/modules/*.conf;
events {
    worker_connections 4096;
}
http {
    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';
    access_log  /var/log/cpcloud/nginx/access.log  main;
    client_max_body_size   1024m;
    gzip                on;
    gzip_min_length     1k;
    gzip_comp_level     2;
    gzip_types          text/plain application/javascript application/x-javascript text/css application/xml text/javascript application/x-httpd-php image/jpeg image/gif image/png;
    gzip_vary           on;
    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 2048;
    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;
    # Load modular configuration files from the /etc/nginx/conf.d directory.
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    # for more information.
    include /etc/nginx/conf.d/*.conf;
}

EOF
}

function install_nginx_ssl() {
    ####配置nginx ssl 证书目录
    test -d /etc/nginx/ssl || mkdir -p /etc/nginx/ssl
    /bin/cp -rp /opt/guacamole_ssl/* /etc/nginx/ssl/
    cat << EOF > /etc/nginx/nginx.conf
#user nginx;
user root;
worker_processes auto;
error_log /var/log/cpcloud/nginx/error.log;
pid /run/nginx.pid;
include /usr/share/nginx/modules/*.conf;
events {
    worker_connections 4096;
}
http {
    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';
    access_log  /var/log/cpcloud/nginx/access.log  main;
    client_max_body_size   1024m;
    gzip                on;
    gzip_min_length     1k;
    gzip_comp_level     2;
    gzip_types          text/plain application/javascript application/x-javascript text/css application/xml text/javascript application/x-httpd-php image/jpeg image/gif image/png;
    gzip_vary           on;
    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 2048;
    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;
    # Load modular configuration files from the /etc/nginx/conf.d directory.
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    # for more information.
    include /etc/nginx/conf.d/*.conf;
}

EOF
}

function config_nginx_default() {
  test -e /etc/nginx/conf.d/default.conf || touch /etc/nginx/conf.d/default.conf
  cat << EOF > /etc/nginx/conf.d/default.conf
server {
    listen       80;
    server_name  localhost;
    include /etc/nginx/default.d/*.conf;
    error_page 404 /404.html;
    location = /40x.html {
    }
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
    }
}
EOF

}

function config_nginx_default_ssl() {
  test -e /etc/nginx/conf.d/default.conf || touch /etc/nginx/conf.d/default.conf
  cat << EOF > /etc/nginx/conf.d/default.conf
server {
    listen       80;
    server_name  localhost;
    return 301 https://\$host\$request_uri;
}
server {
    listen       443 ssl;
    listen       [::]:443 ssl;
    server_name  _;
    ssl_certificate      /etc/nginx/ssl/server.crt;
    ssl_certificate_key  /etc/nginx/ssl/server.key;
    ssl_session_timeout  30m;
    ssl_ciphers  ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4:!DES:!3DES;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers  on;
    root         /usr/share/nginx/html;
    # Load configuration files for the default server block.
    include /etc/nginx/default.d/*.conf;
    # location =/ {
    #    rewrite ^.*$ /cr/red_vs_blue/ redirect;
    # }
    error_page 404 /404.html;
    location = /40x.html {
    }
    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
    }
}
EOF
}

function config_metadata_proxy() {
    cat << EOF > /etc/nginx/conf.d/metadata_proxy.conf
server {
    listen	8081;
    server_name	metadata_proxy;

    location / {
    	proxy_pass http://127.0.0.1:8775;
    }
    location /file/ {
        proxy_pass http://127.0.0.1:8888/;
    }
    location /installer_upload/ {
        alias /home/installer_upload/;
        autoindex on;
        autoindex_exact_size off;
        autoindex_localtime on;
        charset utf-8;
    }
    include /etc/nginx/conf.d/metadata/*.conf;

}
EOF
}


function controller_pass_svcloud_cpcloud() {
  cat << EOF > /etc/nginx/conf.d/pass_sv_cpcloud.conf
server {
    listen	11111;
    server_name	pass_sv_cpcloud;

    location / {
        proxy_pass http://${LOCAL_HOSTNAME}:10009;
        index  index.html index.htm;
        proxy_connect_timeout 600;
        proxy_read_timeout 600;
        proxy_send_timeout 600;
    }

    location /cpcloud {
        proxy_pass http://${LOCAL_HOSTNAME}:9999/knapsack;
        index  index.html index.htm;
        proxy_connect_timeout 600;
        proxy_read_timeout 600;
        proxy_send_timeout 600;
    }

}

EOF

}

function config_guacamole() {
  cat << EOF > /etc/nginx/conf.d/guacamole.conf
server {
        listen 8200;
        server_name localhost;
        location /remote_access/ {
            proxy_pass http://127.0.0.1:9200/guacamole/;
            proxy_buffering off;
            proxy_http_version 1.1;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_cookie_path /guacamole/ /;
            access_log off;
        }
        location /image_exports/ {
            alias /usr/share/image_exports/;
            autoindex on;
            autoindex_exact_size off;
            autoindex_localtime on;
            charset utf-8;
        }
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
}
EOF
}


function config_guacamole_compute() {
  cat << EOF > /etc/nginx/conf.d/guacamole.conf
server {
        listen 8200;
        server_name localhost;
        location /remote_access/ {
            proxy_pass http://127.0.0.1:9200/guacamole/;
            proxy_buffering off;
            proxy_http_version 1.1;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_cookie_path /guacamole/ /;
            access_log off;
        }
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
}
EOF
}

function config_guacamole_ssl() {
    cat << EOF > /etc/nginx/conf.d/guacamole_ssl.conf
server {
        listen 8443 ssl;
        server_name guacamole.xxx.com;
        ssl_certificate      /etc/nginx/ssl/server.crt;
        ssl_certificate_key  /etc/nginx/ssl/server.key;
        ssl_session_timeout  30m;
        ssl_ciphers  ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4:!DES:!3DES;
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
        ssl_prefer_server_ciphers  on;
        location /remote_access/ {
            proxy_pass http://127.0.0.1:9200/guacamole/;
            proxy_buffering off;
            proxy_http_version 1.1;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_cookie_path /guacamole/ /;
            access_log off;
        }
        location /image_exports/ {
            alias /usr/share/image_exports/;
            autoindex off;
            autoindex_exact_size off;
            autoindex_localtime on;
            charset utf-8;
        }
        location /download_record_file/ {
            alias /home/guacamole/;
            autoindex off;
            autoindex_exact_size off;
            autoindex_localtime on;
            charset utf-8;
        }
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
}
EOF

}


function config_test_proxy() {
    test -d /etc/nginx/conf.d/metadata/ || mkdir /etc/nginx/conf.d/metadata/ -pv
    test -d /var/www/html/test || mkdir -pv /var/www/html/test
    test -d  /etc/nginx/default.d  || mkdir -p /etc/nginx/default.d
    echo "test" > /var/www/html/test/index.html

    cat << EOF > /etc/nginx/conf.d/metadata/test.conf
location /test {
    alias	/var/www/html/test;

}
EOF

}


function test_old_backup() {
    # 在一个私有网络的虚拟机中进行测试，测试分为2种
    # 1. 虚拟机所连接网络，不连接路由器,返回结果为 test表示正常
    curl http://169.254.169.254/test/index.html

    # 2. 虚拟机所连接网络，连接路由器，查看169路由下一跳是否还是DHCP口，验证dhcp_agent.ini配置
    # force_metadata = true 是否生效
}


function start_service() {
    nginx -g "daemon off;"
}

function main() {
    if [ "$CURRENT_NODE_TYPE" = "controller" ];then
        if [ "$ENABLE_HTTPS" = "TRUE" ];then
            install_nginx_ssl
            config_guacamole_ssl
            config_nginx_default_ssl
        else
            install_nginx
            config_guacamole
            config_nginx_default
        fi
        controller_pass_svcloud_cpcloud
        config_metadata_proxy
        config_test_proxy
        start_service
    else
        if [ "$ENABLE_HTTPS" = "TRUE" ];then
            install_nginx_ssl
        else
            install_nginx
            config_guacamole_compute
            start_service
        fi
    fi
}

# 测试gzip 压缩开启方式
# curl -H "Accept-Encoding: gzip" -I localhost:80
main


