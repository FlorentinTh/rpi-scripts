#!/bin/bash

if [ $EUID -ne 0 ]; then
        echo "Please run $0 as root"
        exit 2
fi

sed -i '16s/.*/CONF_SWAPSIZE=2048/' /etc/dphys-swapfile
/etc/init.d/dphys-swapfile stop
/etc/init.d/dphys-swapfile start

apt-get update
apt-get upgrade -y

sudo apt-get install -y g++ protobuf-compiler libprotobuf-dev libboost-dev curl m4 wget libssl-dev

cd /tmp/
wget https://download.rethinkdb.com/dist/rethinkdb-2.3.5.tgz
tar xzf rethinkdb-2.3.5.tgz
cd rethinkdb-2.3.5

./configure --allow-fetch
make -j4 ALLOW_WARNINGS=1
make install ALLOW_WARNINGS=1

sed -i '16s/.*/CONF_SWAPSIZE=512/' /etc/dphys-swapfile
/etc/init.d/dphys-swapfile stop
/etc/init.d/dphys-swapfile start

