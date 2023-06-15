#!/usr/bin/env bash
set -e

sudo service udev restart && sudo udevadm control --reload-rules && sudo udevadm trigger

source /home/matlab/ros_ws_34757/devel/setup.bash

exec "$@"
