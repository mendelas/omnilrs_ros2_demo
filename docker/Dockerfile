# FROM osrf/ros:humble-desktop
# ENV ROS_DISTRO=humble

# # Get the latest ROS GPG key
# RUN rm -f /etc/apt/sources.list.d/ros2-latest.list && \
#     apt-get update && apt-get install -y curl gnupg lsb-release && \
#     curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg && \
#     echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null

# # Install dependencies
# RUN apt-get update && \
#     apt-get install -y --no-install-recommends \
#     software-properties-common \
#     git \
#     build-essential \
#     cmake \
#     byobu \
#     vim \
#     wget \
#     unzip \
#     libeigen3-dev \
#     libspdlog-dev \
#     libsuitesparse-dev \
#     qtdeclarative5-dev \
#     qt5-qmake \
#     libqglviewer-dev-qt5 \
#     libopencv-dev \
#     libpcl-dev \
#     libpcl-conversions-dev \
#     libomp-dev \
#     python3-colcon-common-extensions \
#     python3-rosdep \
#     python3-pip \
#     ros-$ROS_DISTRO-rqt-tf-tree \
#     ros-$ROS_DISTRO-joy-linux \
#     ros-$ROS_DISTRO-image-geometry && \
#     rm -rf /var/lib/apt/lists/* && \
#     apt-get clean

# # Check if rosdep needs to be initialized
# RUN if [ ! -f "/etc/ros/rosdep/sources.list.d/20-default.list" ]; then \
#     rosdep init; \
#     fi \
#     && rosdep update

# RUN apt-get update && apt-get install -y ros-$ROS_DISTRO-pcl-*

# # Install nav2 and slamtoolbox
# RUN apt-get update && apt-get install -y \
#     ros-${ROS_DISTRO}-navigation2 \
#     ros-${ROS_DISTRO}-nav2-bringup \
#     ros-${ROS_DISTRO}-slam-toolbox \
#     ros-${ROS_DISTRO}-spatio-temporal-voxel-layer

# # Install foxglove bridge
# RUN apt install -y ros-$ROS_DISTRO-foxglove-bridge

# # Install octomap
# # RUN apt-get install -y ros-${ROS_DISTRO}-octomap-mapping

# COPY requirements.txt /tmp/
# RUN pip3 install --no-cache-dir --upgrade pip \
#     && pip3 install --no-cache-dir -r /tmp/requirements.txt


# WORKDIR /ros2_ws
# RUN echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> /root/.bashrc
# ## For convenience:
# RUN echo "alias kk='clear'" >> /root/.bashrc
# RUN echo "alias tt='tmux new'" >> /root/.bashrc
# RUN echo "alias roskb='ros2 run teleop_twist_keyboard teleop_twist_keyboard'" >> /root/.bashrc
# # Save the bash history immediately on each execution
# RUN echo "export PROMPT_COMMAND='history -a' " >> "/root/.bashrc"
# RUN echo "export HISTFILE=/commandhistory/.bash_history" >> "/root/.bashrc"

# ENTRYPOINT ["/ros_entrypoint.sh"]
# CMD ["bash"]


FROM osrf/ros:humble-desktop

# Prevent interactive prompts during apt installs
ENV DEBIAN_FRONTEND=noninteractive
ENV ROS_DISTRO=humble

# ===============================
# Base dependencies
# - We DO NOT re-add the ROS repo or GPG key here because the base image
#   (osrf/ros:humble-desktop) already provides a working ROS apt source.
# - Re-adding it would cause a "Signed-By conflict" error during apt-get update.
# ===============================
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    software-properties-common \
    git \
    build-essential \
    cmake \
    byobu \
    vim \
    wget \
    unzip \
    libeigen3-dev \
    libspdlog-dev \
    libsuitesparse-dev \
    qtdeclarative5-dev \
    qt5-qmake \
    libqglviewer-dev-qt5 \
    libopencv-dev \
    libpcl-dev \
    libpcl-conversions-dev \
    libomp-dev \
    python3-colcon-common-extensions \
    python3-rosdep \
    python3-pip \
    ros-${ROS_DISTRO}-rqt-tf-tree \
    ros-${ROS_DISTRO}-joy-linux \
    ros-${ROS_DISTRO}-image-geometry && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

# ===============================
# rosdep setup
# Some base images already initialize rosdep.
# We only run rosdep init if it's not initialized.
# Then we always run rosdep update.
# ===============================
RUN if [ ! -f "/etc/ros/rosdep/sources.list.d/20-default.list" ]; then \
    rosdep init; \
    fi && \
    rosdep update

# ===============================
# Extra ROS packages: pcl
# ros-humble-pcl-* pulls in useful PCL-related bridges/utilities.
# ===============================
RUN apt-get update && \
    apt-get install -y ros-${ROS_DISTRO}-pcl-* && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

# ===============================
# Navigation stack / SLAM stack
# - Navigation2
# - Nav2 bringup
# - SLAM Toolbox
# - Spatio-temporal voxel layer (mapping/costmap plugin)
# ===============================
RUN apt-get update && \
    apt-get install -y \
    ros-${ROS_DISTRO}-navigation2 \
    ros-${ROS_DISTRO}-nav2-bringup \
    ros-${ROS_DISTRO}-slam-toolbox \
    ros-${ROS_DISTRO}-spatio-temporal-voxel-layer && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

# ===============================
# Foxglove bridge (ROS <-> Foxglove Studio bridge)
# ===============================
RUN apt-get update && \
    apt-get install -y ros-${ROS_DISTRO}-foxglove-bridge && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

# ===============================
# Python requirements (project-specific)
# We assume requirements.txt exists next to this Dockerfile tree.
# ===============================
COPY requirements.txt /tmp/requirements.txt
RUN pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir -r /tmp/requirements.txt

# ===============================
# Runtime environment setup
# - /ros2_ws is the default workspace inside the container
# - Add quality-of-life aliases
# - Save shell history eagerly to /commandhistory
# ===============================
WORKDIR /ros2_ws
RUN echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> /root/.bashrc && \
    echo "alias kk='clear'" >> /root/.bashrc && \
    echo "alias tt='tmux new'" >> /root/.bashrc && \
    echo "alias roskb=\"ros2 run teleop_twist_keyboard teleop_twist_keyboard\"" >> /root/.bashrc && \
    echo "export PROMPT_COMMAND='history -a'" >> /root/.bashrc && \
    echo "export HISTFILE=/commandhistory/.bash_history" >> /root/.bashrc

# ===============================
# Default entrypoint / command
# ===============================
ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]
