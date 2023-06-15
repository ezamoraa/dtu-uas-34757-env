# dtu-uas-34757-env
Development Environment for DTU UAS 34757 course.
The Docker image contains MATLAB with the required toolboxes,
the ROS workspaces, and the Crazyflie dependencies.

## Setup Instructions
1. Download the docker image from [Docker Hub](https://hub.docker.com/repository/docker/ezamoraa/dtu_uas_34757/general):

```bash
docker pull ezamoraa/dtu_uas_34757
```

2. Run the docker container specifiying a shared folder path:

```bash
./docker-run.sh <shared-path>
```

3. To open more terminals in the running container:

```bash
docker exec -it dtu_uas bash
```

## Build Instructions
You can also build a custom image using the Dockerfile:

```bash
docker build . -t ezamoraa/dtu_uas_34757:test
```
