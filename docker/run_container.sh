#!/bin/bash
set -e

xhost +local:root

IMAGE="omnilrs-navigation:v1.0"
NAME="omnilrs-navigation-container"
RUNTIME_DIR="/tmp/runtime-docker"

mkdir -p "$RUNTIME_DIR"

docker run -it --rm --privileged \
    --gpus=all \
    -e NVIDIA_VISIBLE_DEVICES=all \
    -e NVIDIA_DRIVER_CAPABILITIES=all \
    -e XDG_RUNTIME_DIR="$RUNTIME_DIR" \
    -e ACCEPT_EULA=Y \
    -e PRIVACY_CONSENT=Y \
    -e DISPLAY="$DISPLAY" \
    -v "$HOME/.Xauthority:/root/.Xauthority" \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v /dev/:/dev/ \
    -v "$PWD/docker:/docker" \
    -v "$PWD/humble_ws:/ros2_ws" \
    -v omnilrs_ros2_demo_cmd:/commandhistory \
    --network=host \
    --ipc=host \
    --name "$NAME" \
    "$IMAGE"
