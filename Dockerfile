# Teamspeak3 Server based on debian
# * pulls the latest 64-bit server from the vendor's website
# * customizable UID & GID & ini-file

FROM debian:jessie

MAINTAINER ziermmar

ENV TEAMSPEAK_UID=1000 TEAMSPEAK_GID=1000 TEAMSPEAK_INIFILE=ts3server.ini

# Add User & Group
RUN groupadd -r teamspeak3 --gid=${TEAMSPEAK_GID} && useradd -r -g teamspeak3 --uid=${TEAMSPEAK_UID} teamspeak3

# grab gosu for easy step-down from root
ENV GOSU_VERSION 1.7
RUN set -x \
	&& apt-get update && apt-get install -y --no-install-recommends ca-certificates wget && rm -rf /var/lib/apt/lists/* \
	&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
	&& wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
	&& gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
	&& rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu \
	&& gosu nobody true

# Install dependencies and locale
RUN set -x \
	&& apt-get update \
	&& apt-get -y --no-install-recommends install bzip2 libmariadb2 locales \
	&& rm -rf /var/lib/apt/lits/* \
	&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

ENV LANG en_US.utf8

COPY teamspeak3-start.sh /teamspeak3-start

VOLUME /data
WORKDIR /data

CMD ["/teamspeak3-start"]

EXPOSE 9987/udp 10011 30033

