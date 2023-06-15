# To specify which MATLAB release to install in the container, edit the value of the MATLAB_RELEASE argument.
# Use lowercase to specify the release, for example: ARG MATLAB_RELEASE=r2021b
ARG MATLAB_RELEASE=r2023a

# When you start the build stage, this Dockerfile uses the Ubuntu-based matlab-deps image by default.
# To check the available matlab-deps images, see: https://hub.docker.com/r/mathworks/matlab-deps.
FROM mathworks/matlab-deps:${MATLAB_RELEASE}

# Declare the global argument to use at the current build stage.
ARG MATLAB_RELEASE

# Install mpm dependencies.
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install --no-install-recommends --yes \
    wget \
    unzip \
    ca-certificates \
    && apt-get clean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

# Run mpm to install MATLAB in the target location and delete the mpm installation afterwards.
# If mpm fails to install successfully, then print the logfile in the terminal, otherwise clean up.
RUN wget -q https://www.mathworks.com/mpm/glnxa64/mpm \
    && chmod +x mpm \
    && ./mpm install \
    --release=${MATLAB_RELEASE} \
    --destination=/opt/matlab/${MATLAB_RELEASE} \
    --products MATLAB \
               Computer_Vision_Toolbox \
               Curve_Fitting_Toolbox \
               Image_Processing_Toolbox \
               MATLAB_Coder \
               MATLAB_Compiler \
               MATLAB_Compiler_SDK \
               Optimization_Toolbox \
               Robotics_System_Toolbox \
               ROS_Toolbox \
               Simscape \
               Simscape_Multibody \
               Simulink \
               Simulink_3D_Animation \
               Simulink_Check \
               Simulink_Coder \
               Simulink_Compiler \
               Stateflow \
               UAV_Toolbox \
    || (echo "MPM Installation Failure. See below for more information:" && cat /tmp/mathworks_root.log && false) \
    && rm -f mpm /tmp/mathworks_root.log \
    && ln -s /opt/matlab/${MATLAB_RELEASE}/bin/matlab /usr/bin/matlab

# Add "matlab" user and grant sudo permission.
RUN adduser --shell /bin/bash --disabled-password --gecos "" matlab \
    && echo "matlab ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/matlab \
    && chmod 0440 /etc/sudoers.d/matlab

ENV USER=matlab
USER $USER

# Install ROS
RUN sudo apt update
RUN sudo apt install -y lsb-core curl
RUN sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -
RUN sudo apt update
RUN sudo apt install -y python3-rosdep \
                        python3-rosinstall \
                        python3-rosinstall-generator \
                        python3-wstool \
                        python3-catkin-tools \
                        build-essential
RUN sudo apt install -y ros-noetic-ros-base \
                        ros-noetic-tf \
                        ros-noetic-roslint

RUN sudo rosdep init
RUN rosdep update

# Crazyflie dependencies
RUN sudo apt install -y udev libusb-1.0-0-dev libxcb-xinerama0 python3-pip
RUN sudo python3 -m pip install --upgrade pip
RUN sudo pip install cfclient==2023.6
RUN sudo usermod -a -G plugdev $USER

# Utilities
RUN sudo apt install -y vim ros-noetic-rviz

# Setup ROS workspace
WORKDIR /home/$USER

ENV BASE_ROS_WS=/opt/ros/noetic
ENV ASTA_ROS_WS=/home/$USER/asta_ws
ENV UAS_ROS_WS=/home/$USER/ros_ws_34757
SHELL ["/bin/bash", "-c"]

RUN git config --global user.email "you@example.com"
RUN git config --global user.name "Your Name"

WORKDIR /home/$USER

# ASTA workspace
RUN git clone https://github.com/DavidWuthier/asta_workspace_setup.git

WORKDIR /home/$USER/asta_workspace_setup

RUN sudo chmod +x asta_workspace_setup.sh
RUN ./asta_workspace_setup.sh

# UAS workspace
RUN mkdir -p $UAS_ROS_WS/src
RUN cd $UAS_ROS_WS/src && git clone --recurse-submodules https://gitlab.gbar.dtu.dk/davwu/crazyflie_ros.git

WORKDIR $UAS_ROS_WS

RUN source $ASTA_ROS_WS/vrpn_ws/devel/setup.bash && \
    catkin init && \
    catkin build

COPY files/99-bitcraze.rules /etc/udev/rules.d/99-bitcraze.rules
COPY files/bash_aliases /home/$USER/.bash_aliases

COPY files/docker-entrypoint.sh /docker-entrypoint.sh
RUN sudo chmod +x /docker-entrypoint.sh

RUN echo "source ${UAS_ROS_WS}/devel/setup.bash" >> ~/.bashrc

WORKDIR /home/$USER

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD bash