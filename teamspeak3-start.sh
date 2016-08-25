#!/bin/bash

TEAMSPEAK_VERSION=3.0.13.3
TEAMSPEAK_FILENAME=teamspeak3-server_linux_amd64-$TEAMSPEAK_VERSION.tar.bz2
TEAMSPEAK_CHECKSUM=e9f48c8a9bad75165e3a7c9d9f6b18639fd8aba63adaaa40aebd8114166273ae
TEAMSPEAK_URL=http://dl.4players.de/ts/releases/$TEAMSPEAK_VERSION/$TEAMSPEAK_FILENAME

get_source()
{
	echo "Getting Teamspeak..."
	cd /tmp
	wget -q $TEAMSPEAK_URL
}

check_sum()
{
	echo "Checking checksum..."
	echo "$TEAMSPEAK_CHECKSUM *$TEAMSPEAK_FILENAME" | sha256sum -c -
}

extract_source()
{
	echo "Extracting..."
	tar xfj $TEAMSPEAK_FILENAME
	cp -r -u /tmp/teamspeak3-server_linux_amd64/* /data
	rm $TEAMSPEAK_FILENAME
	rm -rf teamspeak3-server_linux_amd64/
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

	exec ./ts3server $TS3ARGS
}

abort()
{
	echo "Error: $1"
	exit 1
}

## Main

get_source || abort "Couldn't retrieve source."
check_sum || abort "Checksum verification failed."
extract_source || abort "Couldn't extract source."
startup || abort "Startup failed."
