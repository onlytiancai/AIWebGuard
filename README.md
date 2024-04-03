# AIWebGuard

史上最强 AI web 防火墙

## Todo

- doing: 国家和地区黑名单
    - done: 集成 geoip2 模块
    - done: 按国家和地区屏蔽请求
    - done：定时刷新黑名单配置
    - todo: 通过 api 管理黑名单

## 脚本

同步 openresty 配置

    rsync -avP --exclude=.git ~/work/openresty/conf stuff/

安装 openresty 和 geoip2 模块

    cd ~/download/
    sudo apt install libmaxminddb0 libmaxminddb-dev mmdb-bin geoipupdate
    wget https://openresty.org/download/openresty-1.25.3.1.tar.gz
    tar xf openresty-1.25.3.1.tar.gz
    wget -c https://github.com/leev/ngx_http_geoip2_module/archive/refs/tags/3.4.tar.gz -O ngx_http_geoip2_module-3.4.tar.gz
    tar xf ngx_http_geoip2_module-3.4.tar.gz

    cd openresty-1.25.3.1
    ./configure --add-dynamic-module=../ngx_http_geoip2_module-3.4
    make
    sudo make install

    mkdir ~/work
    cd ~/work
    mkdir logs/ conf/ modules/

    find ~/download/openresty-1.25.3.1 -name '*geoip2_module.so'
    cp ~/download/openresty-1.25.3.1/build/nginx-1.25.3/objs/ngx_http_geoip2_module.so modules/

    PATH=/usr/local/openresty/nginx/sbin:$PATH
    export PATH
    nginx -p `pwd`/ -c conf/nginx.conf

下载 MaxMind 免费 IP 库，需要注册后下载

    # 相关 IP 数据和工具
    https://dev.maxmind.com/geoip/geolite2-free-geolocation-data
    https://github.com/maxmind/mmdbinspect

    # 测试工具和 IP 库
    ./mmdbinspect -db ./GeoLite2-City_20240329/GeoLite2-City.mmdb 8.8.8.8

## 参考链接

- https://github.com/unixhot/waf
- https://github.com/openresty/lua-nginx-module
- https://moonbingbing.gitbooks.io/openresty-best-practices/content/index.html
