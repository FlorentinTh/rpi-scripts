#!/bin/bash

if [ $EUID -ne 0 ]; then
    echo "Please run $0 as root"
    exit 2
fi

service_filename="display"

echo "1/ configuring hostname..."
name=
while [[ $name = "" ]]; do
   read -p "Name of the device [ENTER]: " name
done
sed -i '6s/.*/127.0.1.1\t'"$name"'/' /etc/hosts
sed -i '1s/.*/'"$name"'/' /etc/hostname
/etc/init.d/hostname.sh

echo "2/ changing pi user's password..."
runuser -l $SUDO_USER -c 'passwd'

echo "3/ installing updates..."
apt-get update
apt-get -y upgrade

echo "4/ installing tools..."
apt-get install python-pip
pip install RPLCD

echo "4/ setting up LCD display"
runuser -l $SUDO_USER -c 'sudo cp $HOME/'"$service_filename"' /etc/init.d/'"$service_filename"
chmod +x /etc/init.d/$service_filename
update-rc.d $service_filename defaults

echo "4/ rebooting..."
reboot