#!/bin/bash

if [ $EUID -ne 0 ]; then
	echo "Please run $0 as root"
	exit 2
fi

secure_asked=false
base_path="/usr/local/etc/rethinkdb"
conf_file="config.conf"
service_filename="rethinkdb"

cd $base_path

name=
while [[ $name = "" ]]; do
   read -p "Name of the server [ENTER]: " name
done

while
	read -p "Secure the server? (Y/n) " choice
do
	case "$choice" in 
		y|Y ) 
			secure_asked=true
			break;;
		n|N ) 
			break;;
		* ) echo "invalid";;
	esac
done

if $secure_asked; then
	openssl genrsa -out key.pem 2048
	openssl req -new -x509 -key key.pem -out cert.pem -days 3650
fi

function write_conf_file() {
	if [ -f $conf_file ]; then
		rm -Rf $conf_file
	fi

	echo -e "server-name=$name" >> $conf_file
	echo -e "bind=0.0.0.0" >> $conf_file
	echo -e "http-port=8080" >> $conf_file
	echo -e "driver-port=28015" >> $conf_file

	if $secure_asked; then
		echo -e "http-tls-key=/usr/local/etc/rethinkdb/key.pem" >> $conf_file
		echo -e "http-tls-cert=/usr/local/etc/rethinkdb/cert.pem" >> $conf_file
		echo -e "#driver-tls-key=/usr/local/etc/rethinkdb/key.pem" >> $conf_file
		echo -e "#driver-tls-cert=/usr/local/etc/rethinkdb/cert.pem" >> $conf_file
		echo -e "cluster-tls-key=/usr/local/etc/rethinkdb/key.pem" >> $conf_file
		echo -e "cluster-tls-cert=/usr/local/etc/rethinkdb/cert.pem" >> $conf_file
		echo -e "cluster-tls-ca=/usr/local/etc/rethinkdb/cert.pem" >> $conf_file
	fi
}

write_conf_file

runuser -l $SUDO_USER -c 'sudo cp $HOME/rethinkdb_utils/'"$service_filename"' /etc/init.d/'"$service_filename"

chmod +x /etc/init.d/$service_filename

update-rc.d $service_filename defaults

/etc/init.d/rethinkdb start