#!/bin/bash

## author: Endrias A. Damtie
## abstract: this script sends your Internet facing external IP to an email address, using the lightweight SMTP client "sendemail", to the anonymous gorilla mail service.
## the default receiver address is receiver@grr.la, however if a different gorilla mail address is provided, the script will utilize that address.
## avoid using receiver emails other than gorilla mail

senderEmail="sender@endr.ias";
customReceiverEmail="sneezygiraffe@grr.la";

if [ -n "$customReceiverEmail" ];
	then receiverEmail="$customReceiverEmail";
	else receiverEmail="receiver@grr.la";
fi;

checkPPAs(){
	if [ -z $(dpkg -l | grep -o "sendemail") ];
		then sendemailavail=0;
		else sendemailavail=1;
	fi;

	if [ -z $(dpkg -l | grep -o "libio-socket-ssl-perl") ];
		then libioavail=0;
		else libioavail=1;
	fi;

	if [ -z $(dpkg -l | grep -o "libnet-ssleay-perl") ];
		then libnetavail=0;
		else libnetavail=1;
	fi;
}

installPPAs(){
	if [ $sendemailavail == '0' ];
		then apt-get install sendemail;
	fi;

	if [ $libioavail == '0' ];
		then apt-get install libio-socket-ssl-perl;
	fi;

	if [ $libnetavail == '0' ];
		then apt-get install libnet-ssleay-perl;
	fi;
}

getExternalIP(){
	externalIP=$( dig +short "myip.opendns.com" @resolver1.opendns.com );
}

sendExternalIP(){
	sendEmail -f $senderEmail -t $receiverEmail -u "External IP for $(date)" -m "$externalIP" -s mail.guerrillamail.com:25 ;
}

main(){
	checkPPAs;
	installPPAs;
	getExternalIP;
	sendExternalIP;
}

netCheckandSend(){
	while [ 1 ];
	do
		packetLoss=$(ping -w 1 resolver1.opendns.com | grep -o -e "[0-9]\{1,3\}% packet loss" | grep -o -e "^[0-9]\{1,3\}");

		if [ $packetLoss -eq 0 ];
			then main > /dev/null && exit;
		fi;
	done;
}

netCheckandSend;
exit
