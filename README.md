# ASI project data analysis code

This repository is part of my work for my Advanced Science Investigation class at Los Altos High School. This repository contains log files from the robot and code for data analysis.

# Log files

Log files from the robot used for data analysis are available here: https://drive.google.com/drive/folders/1Yx7oCBHHGGLKgIzcHLdge5nvJrTNAXOM?usp=sharing

## Files description

### Data analysis files:
- file_read_test.m - reads log files
- kalman_filter_test.m - initially started out as combining apriltag position data with lidar ICP position using a kalman filter, but now it simply resets the rotation data from the lidar ICP data when it gets data from apriltag localization
- lidar_icp_#.m - Lidar ICP algorithm files. Recommended lidar ICP files to use below.
- lidar_icp_7.m - Lidar ICP using only lidar data
- lidar_icp_with_gyro_angle.m - Lidar ICP using lidar position data and combining it with gyro rotation data
- get_mouse_gyro_position.m - Position using mouse and gyro position.
- main_#.m - main files for lidar ICP
- main_1.m - displays multiple graphs for the path, X coordinate, Y coordiante, and rotation over time for both lidar ICP position and mouse and gyro position
- main_6.m - displays the paths for the lidar ICP and lidar ICP with gyro (have to check though cause it uses lidar_icp_8.m which seems to be a test file)
- export_drift_over_time.m - exports the drift over time using the average deviagtion from the average value over time, didn't work out that well
- analyze_drift_over_time_1.m and analyze_drift_over_time_2.m - displays a visual representation of the drift
- main_visualize_apriltag_path.m - displays the apriltag path
- lidar_data_parser_#.m - used for parsing lidar data initially
- get_apriltag_pos.m - gets apriltag data from the log file

### Path generation files:
- main_generate_paths.m - generates robot path
- verify_path.m - verifies robot path
- get_field.m - this file contains the robot field

## Other info
Toolboxes used:
- MATLAB Lidar Toolbox
- MATLAB parallel computing toolbox

Add-ons used:
- Dijkstra Algorithm: https://www.mathworks.com/matlabcentral/fileexchange/36140-dijkstra-algorithm
