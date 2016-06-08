# Teamspeak3 Server based on debian
# * pulls the latest 64-bit server from the vendor's website
# * customizable UID & GID & ini-file

FROM debian:jessie

MAINTAINER ziermmar

ENV TEAMSPEAK_UID 1000
ENV TEAMSPEAK_GID 1000
ENV TEAMSPEAK_INIFILE ts3server.ini

COPY teamspeak3-start.sh /teamspeak3-start

RUN DEBIAN_FRONTEND=noninteractive \
	apt-get update \
	&& apt-get -y install wget bzip2 libmariadb2 \
        && mkdir -p /data \
        && useradd -M -s /bin/false --uid ${TEAMSPEAK_UID} teamspeak3 \
	&& groupmod --gid ${TEAMSPEAK_GID} teamspeak3 \
	&& chown -R teamspeak3:teamspeak3 /data \
	&& chmod -R g+wX /data /teamspeak3-start

VOLUME /data
WORKDIR /data

USER teamspeak3

CMD ["/teamspeak3-start"]

EXPOSE 9987/udp 10011 30033

