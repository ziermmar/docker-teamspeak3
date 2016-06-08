#!/bin/bash

set -e

TEAMSPEAK_VERSION=3.0.12.4
TEAMSPEAK_FILENAME=teamspeak3-server_linux_amd64-$TEAMSPEAK_VERSION.tar.bz2
TEAMSPEAK_CHECKSUM=6bb0e8c8974fa5739b90e1806687128342b3ab36510944f576942e67df7a1bd9
TEAMSPEAK_URL=http://dl.4players.de/ts/releases/$TEAMSPEAK_VERSION/$TEAMSPEAK_FILENAME

get_source()
{
	echo "Getting Teamspeak..."
	cd /tmp
	gosu teamspeak3 wget -q $TEAMSPEAK_URL
}

check_sum()
{
	echo "Checking checksum..."
	echo "$TEAMSPEAK_CHECKSUM *$TEAMSPEAK_FILENAME" | gosu teamspeak3 sha256sum -c -
}

extract_source()
{
	echo "Extracting..."
	gosu teamspeak3 tar xfj $TEAMSPEAK_FILENAME
	gosu teamspeak3 cp -r -u /tmp/teamspeak3-server_linux_amd64/* /data
	gosu teamspeak3 rm $TEAMSPEAK_FILENAME
	gosu teamspeak3 rm -rf teamspeak3-server_linux_amd64/
}

startup()
{
	echo "Starting up..."
	cd /data
	export LD_LIBRARY_PATH=/data

	echo "Starting with these variables:"
	echo "UID: $TEAMSPEAK_UID"
	echo "GID: $TEAMSPEAK_GID"
	echo "INI: $TEAMSPEAK_INIFILE"

	TS3ARGS=""

	if [[ "${TEAMSPEAK_INIFILE:=false}" ]] && [[ ${TEAMSPEAK_INIFILE} != "false" ]]; then
		echo "Using $TEAMSPEAK_INIFILE"
		TS3ARGS="inifile=${TEAMSPEAK_INIFILE}"
	else
		echo "Creating brand new ini file."
		TS3ARGS="createinifile=1"
	fi

	exec gosu teamspeak3 ./ts3server $TS3ARGS
}

abort()
{
	echo "Error: $1"
	exit 1
}

set_permissions()
{
	usermod --uid ${TEAMSPEAK_UID} teamspeak3
	groupmod --gid ${TEAMSPEAK_GID} teamspeak3

	chown -R teamspeak3:teamspeak3 /data
	chmod -R g+wX /data

}
## Main

set_permissions || abort "Couldn't set permissions."
get_source || abort "Couldn't retrieve source."
check_sum || abort "Checksum verification failed."
extract_source || abort "Couldn't extract source."
startup || abort "Startup failed."
