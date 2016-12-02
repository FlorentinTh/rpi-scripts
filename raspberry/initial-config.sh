#!/bin/bash

if [ $EUID -ne 0 ]; then
    echo "Please run $0 as root"
    exit 2
fi

service_filename="display"

function configure_hostname(){
        echo "Configuring hostname..."
        name=
        while [[ $name = "" ]]; do
                read -p "Name of the device [ENTER]: " name
        done
        sed -i '6s/.*/127.0.1.1\t'"$name"'/' /etc/hosts
        sed -i '1s/.*/'"$name"'/' /etc/hostname
}

function change_user_passwd(){
        echo "Changing pi user's password..."
        runuser -l $SUDO_USER -c 'passwd'
}

function update(){
        echo "Installing updates..."
        apt-get update
        apt-get -y upgrade
}

function install_tools(){
        echo "Installing tools..."
        apt-get install python-pip -y
        pip install RPLCD
}

function setup_LCD(){
        echo "Setting up LCD"
        runuser -l $SUDO_USER -c 'sudo cp $HOME/raspberry_utils/'"$service_filename"' /etc/init.d/'"$service_filename"
        chmod +x /etc/init.d/$service_filename
        update-rc.d $service_filename defaults
}

text="
1- Change hostname
2- Full configuration
Choice [ENTER]: "

while
        read -p "$text" choice do
do
        case "$choice" in
                1 )
                        configure_hostname
                        break;;
                2 )
                        configure_hostname
                        change_user_passwd
                        update
                        install_tools
                        setup_LCD
                        break;;
                * ) echo "invalid";;
        esac
done

echo "Rebooting..."
reboot
