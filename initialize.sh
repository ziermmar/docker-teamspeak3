#!/bin/bash

set -e

usermod --uid $TEAMSPEAK_UID teamspeak3
groupmod --gid $TEAMSPEAK_GID teamspeak3

chown -R teamspeak3:teamspeak3 /data /teamspeak3-start
chmod -R g+wX /data /teamspeak3-start

exec sudo -E -u teamspeak3 /teamspeak3-start "$@"
