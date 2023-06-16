# dtu-uas-34757-env
Development Environment for DTU UAS 34757 course.
The Docker image contains MATLAB with the required toolboxes,
the ROS workspaces, and the Crazyflie dependencies.

## Setup Instructions
First, make sure that Docker is installed following the official [Docker Installation Instructions](https://docs.docker.com/engine/install/).
It is advisable to also follow the [Linux Post-installation steps](https://docs.docker.com/engine/install/linux-postinstall/).
 
1. Download the docker image from [Docker Hub](https://hub.docker.com/repository/docker/ezamoraa/dtu_uas_34757/general):

```bash
./docker-pull.sh
```

2. Run the docker container specifiying a shared folder path between the host and the container:

```bash
./docker-run.sh <shared-path>
```

3. To open more terminals in the running container:

```bash
docker exec -it dtu_uas bash
```

4. To restart an stopped container after a PC reboot (then do exec):

```bash
docker start dtu_uas
```

## Build Instructions
You can also build a custom image:

```bash
make image
```
