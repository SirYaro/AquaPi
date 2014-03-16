﻿/*
 * AquaPi - sterownik akwariowy oparty o Raspberry Pi
 *
 * Copyright (C) 2012-2014 AquaPi Developers
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License Version 2 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307,
 * USA.
 *
 */

#include <sys/socket.h>
#include <netinet/ip.h>
#include <pthread.h>
#include <errno.h>
#include <inttypes.h>
#include <arpa/inet.h>

#define BUF_SIZE 255
#define QUERY_SIZE 1

char buf[BUF_SIZE];
FILE * net;
	
char *XMLHead = "<?xml version=\"1.0\"?>\n"
				"<aquapi>\n";
char *XMLFoot = "</aquapi>\n";

void TCPCommandReload() {
	Log("Otrzymałem polecenie odświerzenia konfiguracji",E_INFO);
	ReadConf();
}

void TCPCommandAbout() {
	Log("Otrzymałem polecenie about",E_DEV);
	char buff[120];

	sprintf(buff,"aquapi>about>beginning of reply.\n");
	fputs(buff,net);
	sprintf(buff,"aquapi>about>Hello, My name is AquaPi\n");
	fputs(buff,net);
	sprintf(buff,"aquapi>about>and I am aquarium computer daemon.\n");
	fputs(buff,net);
	sprintf(buff,"aquapi>about>PID:%i\n",getpid());
	fputs(buff,net);
	sprintf(buff,"aquapi>about>compilation: %s %s\n",build_date,build_time);
	fputs(buff,net);
	sprintf(buff,"aquapi>about>end of reply.\n");
	fputs(buff,net);
	fflush(net);	
}

void TCPCommandStatus() {
	Log("Otrzymałem polecenie status",E_DEV);
	char buff[400];
	int x;
	
	fputs(XMLHead,net);	
	sprintf(buff,"<reply type=\"status\"/>\n");
	fputs(buff,net);
	// przedstaw się ładnie
	sprintf(buff,"<daemon>\n");
	fputs(buff,net);
	sprintf(buff,"<pid>%i</pid>\n",getpid());
	fputs(buff,net);
	sprintf(buff,"<compilation_date>%s %s</compilation_date>\n",build_date,build_time);
	fputs(buff,net);
	sprintf(buff,"</daemon>\n");
	fputs(buff,net);
	// opowiedz co tam panie słychać w urządzonkach
	sprintf(buff,"<devices>\n");
	fputs(buff,net);

	for(x = 0; x <= interfaces_count; x++) {
		sprintf(buff,"<device id=\"%i\"><address>%s</address><name>%s</name><type>%i</type><state>%i</state><id>%i</id><measured_value>%f</measured_value></device>\n",interfaces[x].id,interfaces[x].address,interfaces[x].name,interfaces[x].type,interfaces[x].state,interfaces[x].id,interfaces[x].measured_value);
		fputs(buff,net);
	}	
	
	sprintf(buff,"</devices>\n");
	fputs(buff,net);
	fputs(XMLFoot,net);
	fflush(net);		
}

void* TCPConnections (void* unused) {
	char buff[200];
	// gniazdo ...
	int sh = socket(PF_INET, SOCK_STREAM, 0);
	if (sh<0) {
	sprintf(buff,"Błąd TCPIP: %s",strerror(errno));
	Log(buff,E_CRIT);
	exit(EXIT_FAILURE);
	}

	// utworzenie struktury opisującej adres
	struct sockaddr_in serwer;
	serwer.sin_family=AF_INET;
	serwer.sin_port=htons(config.port);
	// serwer.sin_addr.s_addr=INADDR_ANY; // INADDR_ANY oznacza że nasłuchujemy na każdym adresie IP danego hosta
	serwer.sin_addr.s_addr=inet_addr(config.interface);

	// przypisanie adresu ...
	if (bind(sh, (struct sockaddr *) &serwer, sizeof(struct sockaddr_in)) < 0) {
		sprintf(buff,"Błąd TCPIP: %s",strerror(errno));
		Log(buff,E_CRIT);
		exit(EXIT_FAILURE);
	}

	sprintf(buff,"Zaczynam nasłuchiwać na %s:%i",config.interface,config.port);
	Log(buff,E_INFO);
		
	while(1) {
		// otwarcie portu do nasluchiwania
		if (listen(sh, QUERY_SIZE) < 0) {
			sprintf(buff,"Błąd TCPIP: %s",strerror(errno));
			Log(buff,E_CRIT);
			exit(EXIT_FAILURE);
		}


		// odebranie połączenia
		struct sockaddr_in from;
		socklen_t fromlen=sizeof(struct sockaddr_in);
		int sh2 = accept(sh, (struct sockaddr *) &from, &fromlen);
		// obsługa komend
		net=fdopen(sh2, "r+");
		while(fgets(buf, BUF_SIZE, net)) {
			if (strncmp("aquapi:reload",buf,13)==0) {
				TCPCommandReload();
				shutdown(sh2,SHUT_RDWR);
			} 
			if (strncmp("aquapi:about",buf,12)==0) {
				TCPCommandAbout();
				shutdown(sh2,SHUT_RDWR);
			}
			if (strncmp("aquapi:status",buf,13)==0) {
				TCPCommandStatus();
				shutdown(sh2,SHUT_RDWR);
			}	
		}
		fclose(net);
		close(sh2);
	}
	// zamkniecie gniazda
	close(sh);
}

int InitTCP () {
	pthread_t id; // ID naszego wątku
    // Tworzymy nowy wątek, nie przekazujemy atrybutów ani agrumentów funkcji.
    pthread_create (&id, NULL, &TCPConnections, NULL);
    return 0;
} 