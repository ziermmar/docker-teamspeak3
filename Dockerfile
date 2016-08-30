# Teamspeak3 Server based on debian
# * pulls the latest 64-bit server from the vendor's website
# * customizable UID & GID & ini-file

FROM debian:jessie

MAINTAINER ziermmar

ENV TEAMSPEAK_INI=ts3server.ini \
    LANG=en_US.utf8 \
    TEAMSPEAK_VERSION=3.0.13.3 \
    TEAMSPEAK_FILENAME=teamspeak3-server_linux_amd64-3.0.13.3.tar.bz2 \
    TEAMSPEAK_CHECKSUM=e9f48c8a9bad75165e3a7c9d9f6b18639fd8aba63adaaa40aebd8114166273ae \
    TEAMSPEAK_URL=http://dl.4players.de/ts/releases/3.0.13.3/teamspeak3-server_linux_amd64-3.0.13.3.tar.bz2 \
    TEAMSPEAK_WORKDIR=/opt/teamspeak3

RUN groupadd --system teamspeak3 --gid=1000 && \
    useradd --system --gid teamspeak3 --uid=1000 teamspeak3

VOLUME ${TEAMSPEAK_WORKDIR}/data

VOLUME ${TEAMSPEAK_WORKDIR}/files

RUN set -x && \
    apt-get update && \
    apt-get -y --no-install-recommends install bzip2 libmariadb2 locales wget && \
    rm -rf /var/lib/apt/lits/* && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 && \
    mkdir -p ${TEAMSPEAK_WORKDIR} ${TEAMSPEAK_WORKDIR}/data ${TEAMSPEAK_WORKDIR}/files && \
    chown -R teamspeak3:teamspeak3 ${TEAMSPEAK_WORKDIR}

USER teamspeak3

WORKDIR /opt/teamspeak3

RUN echo "Downloading Teamspeak3 Server..." && \
    wget -q "$TEAMSPEAK_URL" && \
    echo "Validating checksum..." && \
    echo "$TEAMSPEAK_CHECKSUM *$TEAMSPEAK_FILENAME" | sha256sum -c - 

COPY teamspeak3-start.sh /teamspeak3-start

CMD /teamspeak3-start

EXPOSE 9987/udp 10011 30033

