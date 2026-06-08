# Minimal ROS 2 Humble image for the maestree_test_tree BehaviorTree.CPP app.
# Only what the tree needs: BehaviorTree.CPP + colcon build tools.
# No aerostack2, no GUI, no simulator — main.cpp uses behaviortree_cpp and
# ament_index_cpp only (no rclcpp/DDS), so this stays small.
FROM ros:humble-ros-base

RUN apt-get update && apt-get install -y --no-install-recommends \
        ros-humble-behaviortree-cpp \
        python3-colcon-common-extensions \
        build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /maestree_test_tree
