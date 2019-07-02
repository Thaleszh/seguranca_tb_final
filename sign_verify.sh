#!/bin/bash

echo "Doing $1 operation on file $3"
if [ "$1" == "sign" ]; then
	if [ "$#" -lt 3 ]; then
		echo -e "\nIvalid Usage\nUsage: $0 sign <pcks12_file> <document>"
	else
		echo -ne "Password for file:\n"

		read -s password
		openssl pkcs12 -in $2 -nocerts -nodes -password pass:$password | openssl rsa > /tmp/$2.id_rsa
		unset password

		openssl dgst -sha256 -sign /tmp/$2.id_rsa -out $3.sha256 $3

		rm /tmp/$2.id_rsa

		echo "Assinatura escrita em $3.sha256"

	fi

elif [ "$1" == "verify" ]; then
	if [ "$#" -lt 4 ]; then
		if [ "$#" -lt 3 ]; then
		echo -e "\nInvalid Usage\nUsage: $0 verify <public key> <document> [optional: <signature>]"
		else
			openssl dgst -sha256 -verify $2 -signature $3.sha256 $3
		fi
	else
		openssl dgst -sha256 -verify $2 -signature $4 $3
	fi

elif [ "$1" == "public_key" ]; then
	if [ "$#" -lt 3 ]; then
		if [ "$#" -lt 2 ]; then
		echo -e "\nInvalid Usage\nUsage: $0 public_key <pcks12_file>  [optional: <key_name>]"
		else
			echo -ne "Password for file:\n"
			read -s password
			openssl pkcs12 -in $2 -clcerts -nokeys -password pass:$password -out /tmp/$2.crt
			unset password

			openssl x509 -in /tmp/$2.crt -pubkey -noout > $2.pub
			rm /tmp/$2.crt

			echo "Saved public key as $2.pub"
		fi
	else
		echo -ne "Password for file:\n"
		read -s password
		openssl pkcs12 -in $2 -clcerts -nokeys -password pass:$password -out /tmp/$2.crt
		unset password

		openssl x509 -in /tmp/$2.crt -pubkey -noout > $3
		rm /tmp/$2.crt

		echo "Saved public key as $2.pub"
	fi
	
else
	echo "Only sign, verify  and public_key operations supported"
fi
