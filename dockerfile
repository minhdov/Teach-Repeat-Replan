# Use the official Ubuntu 16.04 as a parent image
FROM ubuntu:16.04

# Set environment variables
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# Set non-interactive mode
ENV DEBIAN_FRONTEND noninteractive

# Install git
RUN apt-get update && apt-get install -y git

# Add ROS repository
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    software-properties-common && \
    add-apt-repository "deb http://packages.ros.org/ros/ubuntu xenial main" && \
    apt-get update

# Install ROS Kinetic and additional packages
RUN apt-get install -y --no-install-recommends \
    --allow-unauthenticated \
    ros-kinetic-desktop-full \
    ros-kinetic-joy \
    ros-kinetic-stage \
    ros-kinetic-stage-ros \
    ros-kinetic-simulators \
    ros-kinetic-urdf-tutorial \
    libnlopt-dev \
    libf2c2-dev \
    libarmadillo-dev \
    glpk-utils \
    libglpk-dev \
    libcdd-dev \
    && rm -rf /var/lib/apt/lists/*

# Add GCC 7 from PPA
RUN add-apt-repository ppa:ubuntu-toolchain-r/test && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    gcc-7 \
    g++-7 && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-5 60 --slave /usr/bin/g++ g++ /usr/bin/g++-5 && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 50 --slave /usr/bin/g++ g++ /usr/bin/g++-7

# Install necessary build tools
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    && rm -rf /var/lib/apt/lists/*
    
# Create a directory for your Catkin workspace
RUN mkdir -p /your_catkin_ws/src

# Clone your repository inside the workspace
RUN cd /your_catkin_ws/src && \
    git clone https://github.com/HKUST-Aerial-Robotics/Teach-Repeat-Replan.git

# Navigate to the Catkin workspace
WORKDIR /your_catkin_ws

# Install OpenNI2 development package
RUN apt-get update && apt-get install -y libopenni2-dev && rm -rf /var/lib/apt/lists/*
# Install libpcap and libpng development packages
RUN apt-get update && apt-get install -y libpcap-dev libpng-dev && rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y apt-utils


# Build your code
RUN /bin/bash -c "source /opt/ros/kinetic/setup.bash && \
                  catkin_make"

# Source the setup file to make ROS aware of your package
RUN echo "source /your_catkin_ws/devel/setup.bash" >> ~/.bashrc


# Initialize rosdep
RUN rosdep init && \
    rosdep update

# Environment setup
RUN echo "source /opt/ros/kinetic/setup.bash" >> ~/.bashrc

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Define the entry point for the container
CMD ["bash"]
