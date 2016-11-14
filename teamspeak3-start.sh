#!/bin/bash

get_variables()
{
	# As long as Teamspeak won't change its website layout, this could work...

	echo "Getting Variables..."
	cd /tmp
	wget -q -O /tmp/ts3.version https://www.teamspeak.com/downloads
	TEAMSPEAK_VERSION=$(cat /tmp/ts3.version| xmllint --html --xpath '//*[@id="ts-downloads"]/li[2]/div[3]/div[2]/div[1]/div/span[1]' - 2>/dev/null | grep -o -P '\d+\.\d+\.\d+\.\d+')
	TEAMSPEAK_CHECKSUM=$(cat /tmp/ts3.version| xmllint --html --xpath '//*[@id="ts-downloads"]/li[2]/div[3]/div[2]/div[1]/div/span[2]' - 2>/dev/null | cut -c60-123)
	TEAMSPEAK_FILENAME=teamspeak3-server_linux_amd64-$TEAMSPEAK_VERSION.tar.bz2
	TEAMSPEAK_URL=http://dl.4players.de/ts/releases/$TEAMSPEAK_VERSION/$TEAMSPEAK_FILENAME
	rm /tmp/ts3.version
	echo "Version: $TEAMSPEAK_VERSION"
	echo "Checksum: $TEAMSPEAK_CHECKSUM"
	echo "URL: $TEAMSPEAK_URL"

	if [[ -z $TEAMSPEAK_VERSION ]]; then abort "Couldn't get current version"; fi
	if [[ -z $TEAMSPEAK_CHECKSUM ]]; then abort "Couldn't get current checksum"; fi
}

get_source()
{
	echo "Getting Teamspeak..."
	cd /tmp
	wget -q $TEAMSPEAK_URL
}

check_sum()
{
	echo "Checking checksum..."
	cd /tmp
	echo "$TEAMSPEAK_CHECKSUM *$TEAMSPEAK_FILENAME | sha256sum -c -"
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

get_variables || abort "Couldn't get variables."
get_source || abort "Couldn't retrieve source."
check_sum || abort "Checksum verification failed."
extract_source || abort "Couldn't extract source."
startup || abort "Startup failed."
