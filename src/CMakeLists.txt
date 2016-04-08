# Create a simple LCM publisher for testing

add_executable(example_send_lcm example_send_lcm.cpp)
target_link_libraries( example_send_lcm
    ${LCM_LIBRARY}
    ${catkin_LIBRARIES}
)
add_dependencies(example_send_lcm
    ${${PROJECT_NAME}_EXPORTED_TARGETS} 
    ${catkin_EXPORTED_TARGETS}
)

