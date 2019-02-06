FROM osrf/ros:kinetic-desktop-full

# setup sources.list
RUN echo "deb http://packages.ros.org/ros/ubuntu `lsb_release -sc` main" > /etc/apt/sources.list.d/ros-latest.list

# setup keys
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 421C365BD9FF1F717815A3895523BAEEB01FA116


# update apt
RUN apt-get update

# install TIAGo specific ROS packages
RUN apt-get install -q -y \
	git python-rosinstall \
	ros-kinetic-desktop-full \
    python-catkin-tools \
    ros-kinetic-joint-state-controller \
    ros-kinetic-twist-mux \
    ros-kinetic-ompl \
    ros-kinetic-controller-manager \
    ros-kinetic-moveit-core \
    ros-kinetic-moveit-ros-perception \
    ros-kinetic-moveit-ros-move-group \
    ros-kinetic-moveit-kinematics \
    ros-kinetic-moveit-ros-planning-interface \
    ros-kinetic-moveit-simple-controller-manager \
    ros-kinetic-moveit-planners-ompl \
    ros-kinetic-joy \
    ros-kinetic-joy-teleop \
    ros-kinetic-teleop-tools \
    ros-kinetic-control-toolbox \
    ros-kinetic-sound-play \
    ros-kinetic-navigation \
    ros-kinetic-eband-local-planner \
    ros-kinetic-depthimage-to-laserscan \
    ros-kinetic-openslam-gmapping \
    ros-kinetic-gmapping \
    ros-kinetic-moveit-commander

# install ROS Tiago
RUN mkdir -p /workspace/ROS/tiago_ws/src

COPY tiago_public.rosinstall /workspace/ROS/tiago_ws/tiago_public.rosinstall

RUN /bin/bash -c "cd /workspace/ROS/tiago_ws && \
	rosinstall src /opt/ros/kinetic tiago_public.rosinstall"

RUN apt-get install -y ros-kinetic-humanoid-nav-msgs ros-kinetic-four-wheel-steering-controller

# fill in any missing ROS packages
# RUN ["/bin/bash", "-c", "source /opt/ros/kinetic/setup.bash && cd /workspace/ROS/tiago_ws && rosdep update && rosdep install --from-paths src --ignore-src --rosdistro kinetic --skip-keys=\"opencv2 opencv2-nonfree pal_laser_filters speed_limit sensor_to_cloud hokuyo_node libdw-dev python-graphitesend-pip python-statsd pal_filters pal_vo_server pal_usb_utils pmb2_rgbd_sensors tiago_gazebo pmb2_2dnav tiago_controller_configuration tiago_bringup tiago_2dnav\""]

# install person detector
RUN /bin/bash -c "cd /workspace/ROS/tiago_ws/src \
    && git clone https://github.com/pal-robotics/pal_person_detector_opencv.git"

RUN /bin/bash -c "source /opt/ros/kinetic/setup.bash \
    && cd /workspace/ROS/tiago_ws \
	&& catkin build -DCATKIN_ENABLE_TESTING=0"

# # source ROS environment
RUN echo "source /workspace/ROS/tiago_ws/src/setup.bash --extend" >> /root/.bashrc
RUN echo "source /workspace/ROS/tiago_ws/devel/setup.bash --extend" >> /root/.bashrc

# clean up
RUN rm /workspace/ROS/tiago_ws/tiago_public.rosinstall \
    && apt-get autoclean \
    && apt-get clean all \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* /var/tmp/*

# RUN apt-get install -y ros-kinetic-turtlebot