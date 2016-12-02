#!/bin/bash

line_number=62
conf_file_path="/etc/redis/6379.conf"

if [ $EUID -ne 0 ]; then
        echo "Please run $0 as root"
        exit 2
fi

apt-get install -y build-essential tcl8.5

cd /tmp
wget http://download.redis.io/releases/redis-stable.tar.gz
tar xzf redis-stable.tar.gz

cd redis-stable

make -j4
# make -j4 test
make install

cd utils
./install_server.sh

sed -i ''"$line_number"'s/.*/0.0.0.0/' $conf_file_path

update-rc.d redis_6379 defaults
