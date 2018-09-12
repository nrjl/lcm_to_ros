cmake_minimum_required(VERSION 2.8.3)
project(lcm_to_ros)

find_package(catkin REQUIRED COMPONENTS
  roscpp
  std_msgs
  message_generation
)

SET(CMAKE_MODULE_PATH ${${PROJECT_NAME}_SOURCE_DIR}/cmake)

find_package(lcm REQUIRED)
if (LCM_FOUND)
    include_directories(${LCM_INCLUDE_DIRS})
    # add_subdirectory(src)
endif (LCM_FOUND)

################################################
## Declare ROS messages, services and actions ##
################################################

FILE(GLOB rosMsgFiles RELATIVE "${${PROJECT_NAME}_SOURCE_DIR}/msg" 
    "${${PROJECT_NAME}_SOURCE_DIR}/msg/*.msg")

FOREACH(rosMsg ${rosMsgFiles})
    MESSAGE( STATUS "Processing message file: ${rosMsg}" )
    add_message_files( FILES ${rosMsg})
ENDFOREACH(rosMsg)

generate_messages(
  DEPENDENCIES
  std_msgs
)

###################################
## catkin specific configuration ##
###################################
catkin_package(
#  INCLUDE_DIRS ${CMAKE_SOURCE_DIR}/${PROJECT_NAME}
#  LIBRARIES lcm_to_ros
  CATKIN_DEPENDS roscpp std_msgs message_runtime
#  DEPENDS system_lib
)

###########
## Build ##
###########

# include_directories(include)
include_directories( 
    ${${PROJECT_NAME}_SOURCE_DIR}
    ${catkin_INCLUDE_DIRS} 
)

## Declare a C++ library
# add_library(lcm_to_ros
#   src/${PROJECT_NAME}/lcm_to_ros.cpp
# )

add_subdirectory(src)

get_filename_component(_fullPath autosrc ABSOLUTE)
if(EXISTS ${_fullPath}/CMakeLists.txt)
    add_subdirectory(autosrc)
endif(EXISTS ${_fullPath}/CMakeLists.txt)

#############
## Install ##
#############


#############
## Testing ##
#############


