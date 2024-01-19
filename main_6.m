%logfilename = './logs/path_3_23_11_19_22_24_02.log';
%logfilename = './logs/path_1_long_23_11_19_06_29_48.log';
clear file_read_test;
logfilename = './apriltag-logs/path_54_23_12_13_03_36_24.log';
error_file_name = get_error_file_name(logfilename);

close all;

file_read_test(logfilename);
file_read_test();

for i=4:4

    startEndTimes = get_start_end_times();
    time1 = startEndTimes{i};
    time2 = startEndTimes{i+1};
    
    [lidar_times, xTransform, yTransform, angleTransform, ...
        xOverTime, yOverTime, angleOverTime, rmseOvertime] = lidar_icp_7(logfilename, time1, time2);
    
    [lidar_timesG, xTransformG, yTransformG, angleTransformG, ...
        xOverTimeG, yOverTimeG, angleOverTimeG, rmseOvertimeG] = lidar_icp_8(logfilename, time1, time2);
    
    figure(i);
    title('Path');
    hold on;
    plot(xOverTime, yOverTime, 'b');
    plot(xOverTimeG, yOverTimeG, 'r');
    legend('Lidar', 'Gyro + Lidar');

end