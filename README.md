# Teamspeak3 Server
* based on the latest debian image
* runs as non-root (user id customizable)
* automatically downloads latest Teamspeak3 Server release
* ephemeral


## Example startup:
```
docker run -d -p 9987:9987/udp -p 30033:30033 ziermmar/teamspeak3
```


## Example with custom UID/GID:
```
docker run -d -p 9987:9987/udp -p 30033:30033 -e TEAMSPEAK_UID=2000 -e TEAMSPEAK_GID=2000 -e TEAMSPEAK_INI=ts3_example.com.ini -v /my_ts3_data:/data --name ts3_example.com
```

## Example systemd unit:
```
[Unit]
Description=Teamspeak3 Server: teamspeak.example.com
After=docker.service
Requires=docker.service

[Service]
Restart=always
ExecStartPre=/usr/bin/docker pull ziermmar/teamspeak3
ExecStart=/usr/bin/docker run \
--env TEAMSPEAK_UID=2000 \
--env TEAMSPEAK_GID=2000 \
--env TEAMSPEAK_INIFILE=teamspeak.example.com.ini \
--publish 9987:9987/udp \
--publish 10011:10011 \
--publish 30033:30033 \
--volume /var/virtual/mounts/teamspeak.example.com:/data \
--name teamspeak.example.com \
ziermmar/teamspeak3
ExecStop=/usr/bin/docker stop -t 2 teamspeak.example.com
ExecStopPost=/usr/bin/docker rm -f teamspeak.example.com

[Install]
WantedBy=multi-user.target
```

## Example start/stop script:
```
#!/bin/sh

DOCKER=/usr/bin/docker
DOCKER_IMAGE=ziermmar/teamspeak3
CONTAINER_NAME=teamspeak.example.com

TS3_UID=2000
TS3_GID=2000
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
