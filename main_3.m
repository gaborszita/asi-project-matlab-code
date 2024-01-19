logfilename = './logs/path_1_long_23_10_31_06_27_14.log';
error_file_name = get_error_file_name(logfilename);

file_read_test(logfilename);
file_read_test();

startEndTimes = get_start_end_times();
drifts = zeros(2, length(startEndTimes));

parfor i = 1:length(startEndTimes)-1
    
    time1 = startEndTimes{i, 1};
    time2 = startEndTimes{i, 2};
    
    %[mouse_gyro_times, xTransformMG, yTransformMG, angleTransformMG, ...
    %    xOverTimeMG, yOverTimeMG, angleOverTimeMG] = get_mouse_gyro_pos(time1, time2);
    
    [lidar_times, xTransform, yTransform, angleTransform, ...
        xOverTime, yOverTime, angleOverTime, rmseOvertime] = lidar_icp_4(logfilename, time1, time2);
 
    drifts(:, i) = [xTransform, yTransform];
    
    disp(['Progress: ' num2str(i) '/' num2str(length(startEndTimes))]);
end

writematrix(drifts, error_file_name);