FROM isaac-sim-omnilrs:latest

ENV DEBIAN_FRONTEND=noninteractive
ENV ROS_DISTRO=humble
ENV NVIDIA_DRIVER_CAPABILITIES=compute,graphics,utility
WORKDIR /root

# --------------------------
# 1. Base deps
# --------------------------
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    software-properties-common \
    git build-essential cmake byobu vim wget unzip \
    libeigen3-dev libspdlog-dev libsuitesparse-dev libomp-dev \
    python3-colcon-common-extensions python3-rosdep python3-pip \
    libboost-all-dev libmetis-dev libfmt-dev libglm-dev \
    libglfw3-dev libpng-dev libjpeg-dev libqglviewer-dev-qt5 \
    libopencv-dev libpcl-dev \
    qtdeclarative5-dev qt5-qmake \
    # OpenGL / X11 (viewer 用)
    libgl1-mesa-dev libglu1-mesa-dev freeglut3-dev \
    libxrandr-dev libxinerama-dev libxcursor-dev libxi-dev \
    # ← ここが重要：freetype/fontconfig の dev を明示
    libfreetype6-dev libfontconfig1-dev \
    # ROS 追加
    ros-${ROS_DISTRO}-rqt-tf-tree \
    ros-${ROS_DISTRO}-joy-linux \
    ros-${ROS_DISTRO}-image-geometry \
    ros-${ROS_DISTRO}-navigation2 \
    ros-${ROS_DISTRO}-nav2-bringup \
    ros-${ROS_DISTRO}-slam-toolbox \
    ros-${ROS_DISTRO}-spatio-temporal-voxel-layer \
    ros-${ROS_DISTRO}-foxglove-bridge \
    ros-${ROS_DISTRO}-pcl-conversions \
    && rm -rf /var/lib/apt/lists/* && apt-get clean

# rosdep init/update
RUN if [ ! -f "/etc/ros/rosdep/sources.list.d/20-default.list" ]; then \
    rosdep init; \
    fi && \
    rosdep update

# Python deps
COPY requirements.txt /tmp/requirements.txt
RUN pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir -r /tmp/requirements.txt

# --------------------------
# 2. Build & install GTSAM
# --------------------------
WORKDIR /root
RUN git clone https://github.com/borglab/gtsam && \
    cd gtsam && git checkout 4.3a0 && \
    mkdir build && cd build && \
    cmake .. \
    -DGTSAM_BUILD_EXAMPLES_ALWAYS=OFF \
    -DGTSAM_BUILD_TESTS=OFF \
    -DGTSAM_WITH_TBB=OFF \
    -DGTSAM_USE_SYSTEM_EIGEN=ON \
    -DGTSAM_BUILD_WITH_MARCH_NATIVE=OFF && \
    make -j"$(nproc)" && \
    make install && \
    ldconfig

# --------------------------
# 3. Build & install iridescence
# --------------------------
WORKDIR /root
RUN git clone --recursive https://github.com/koide3/iridescence && \
    cd iridescence && mkdir build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release && \
    make -j"$(nproc)" && \
    make install && \
    ldconfig

# --------------------------
# 4. Build & install gtsam_points (CUDA ON)
# --------------------------
WORKDIR /root
RUN git clone https://github.com/koide3/gtsam_points && \
    cd gtsam_points && mkdir build && cd build && \
    cmake .. -DBUILD_WITH_CUDA=ON && \
    make -j"$(nproc)" && \
    make install && \
    ldconfig

# --------------------------
# 5. ROS workspace with GLIM
# --------------------------
WORKDIR /ros2_ws/src
RUN git clone https://github.com/koide3/glim && \
    git clone https://github.com/koide3/glim_ros2

WORKDIR /ros2_ws

RUN apt-get update && \
    rosdep install --from-paths src --ignore-src -r -y && \
    rm -rf /var/lib/apt/lists/*

SHELL ["/bin/bash", "-c"]

RUN source /opt/ros/${ROS_DISTRO}/setup.bash && \
    colcon build --cmake-args \
    -DBUILD_WITH_CUDA=ON \
    -DBUILD_WITH_VIEWER=ON \
    -DBUILD_WITH_MARCH_NATIVE=OFF

# --------------------------
# 6. Shell quality-of-life
# --------------------------
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> /root/.bashrc && \
    echo "source /ros2_ws/install/setup.bash" >> /root/.bashrc && \
    echo "alias kk='clear'" >> /root/.bashrc && \
    echo "alias roskb=\"ros2 run teleop_twist_keyboard teleop_twist_keyboard\"" >> /root/.bashrc && \
    echo "export PROMPT_COMMAND='history -a'" >> /root/.bashrc && \
    echo "export HISTFILE=/commandhistory/.bash_history" >> /root/.bashrc

WORKDIR /ros2_ws
ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]
