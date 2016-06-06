# Teamspeak3 Server

## Example startup:
```
docker run -d -p 9987:9987/udp -p 30033:30033 ziermmar/teamspeak3
```

## Example start script:

```
#!/bin/sh

DOCKER=/usr/bin/docker
DOCKER_IMAGE=ziermmar/teamspeak3
CONTAINER_NAME=teamspeak.example.com

TS3_UID=5038
TS3_GID=5038
TS3_INI_FILE=teamspeak.example.com.ini
TS3_VOICE_PORT=9987
TS3_QUERY_PORT=10011
TS3_FILES_PORT=30033
TS3_DATA_DIR=/var/virtual/mounts/$CONTAINER_NAME

case "$1" in
	start)
		$DOCKER run \
			-d \
			-e TEAMSPEAK_UID=$TS3_UID \
			-e TEAMSPEAK_GID=$TS3_GID \
			-e TEAMSPEAK_INIFILE=$TS3_INI_FILE \
			-p $TS3_VOICE_PORT:9987/udp \
			-p $TS3_QUERY_PORT:10011 \
			-p $TS3_FILES_PORT:30033 \
			-v $TS3_DATA_DIR:/data \
			--name $CONTAINER_NAME \
			$DOCKER_IMAGE \
		;;

	stop)
		$DOCKER stop -t 2 $CONTAINER_NAME
		$DOCKER rm -f $CONTAINER_NAME
		;;
	status)
		$DOCKER stats $CONTAINER_NAME
		;;
	*)
		echo $"Usage: $0 {start|stop|status}"
		exit 1
esac
```