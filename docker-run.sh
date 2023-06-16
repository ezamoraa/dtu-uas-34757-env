#!/bin/bash
SHARED_DIR=${1:-$(pwd)}
VERSION=${VERSION:-`cat version`}

docker run -it \
    --name dtu_uas \
    -e DISPLAY=$DISPLAY \
    --privileged \
	--network host \
	-v /tmp/.X11-unix:/tmp/.X11-unix:ro \
	-v $SHARED_DIR:/home/matlab/shared \
	-v /dev:/dev \
	--shm-size=512M \
	ezamoraa/dtu_uas_34757:$VERSION bash
