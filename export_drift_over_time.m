logfilename = './logs/path_1_long_23_10_31_06_27_14.log';
error_file_name = get_error_file_name(logfilename);

file_read_test(logfilename);
file_read_test();

startEndTimes = get_start_end_times();
startidx = 1;
endidx = length(startEndTimes)-1;

xOverTimeAll = cell(endidx-startidx+1, 1);
yOverTimeAll = cell(endidx-startidx+1, 1);
angleOverTimeAll = cell(endidx-startidx+1, 1);
lidarTimesAll = cell(endidx-startidx+1, 1);

%[mouse_gyro_times, xTransformMG, yTransformMG, angleTransformMG, ...
%    xOverTimeMG, yOverTimeMG, angleOverTimeMG] = get_mouse_gyro_pos(time1, time2);

parfor idx = 1:endidx-startidx+1
    i = idx + startidx - 1;
    time1 = startEndTimes{i};
    time2 = startEndTimes{i+1};

    [lidar_times, xTransform, yTransform, angleTransform, ...
        xOverTime, yOverTime, angleOverTime, rmseOvertime] = lidar_icp_4(logfilename, time1, time2);
    
    xOverTimeAll{idx} = xOverTime';
    yOverTimeAll{idx} = yOverTime';
    angleOverTimeAll{idx} = angleOverTime';
    lidarTimesAll{idx} = lidar_times';

    disp(['Progress: ' num2str(i) '/' num2str(endidx-startidx+1)]);
end

writecell(xOverTimeAll, 'xovertimeall.csv');
writecell(yOverTimeAll, 'yovertimeall.csv');
writecell(angleOverTimeAll, 'angleovertimeall.csv');
writecell(lidarTimesAll, 'lidartimesall.csv')

%figure(1);
%clf
%hold on;
%title('X');
%plot(lidar_times, xOverTime, 'b');
%plot(mouse_gyro_times, xOverTimeMG, 'r');
%legend('Lidar', 'Mouse+Gyro');
%figure(2);
%clf
%hold on;
%title('Y');
%plot(lidar_times, yOverTime, 'b');
%plot(mouse_gyro_times, yOverTimeMG, 'r');
%legend('Lidar', 'Mouse+Gyro');
%figure(3);
%clf
%hold on;
%title('Rotation');
%grid on;
%plot((lidar_times-0.009*10^10), angleOverTime, 'b');
%plot(mouse_gyro_times, angleOverTimeMG, 'r');
%figure(4);
%clf
%hold on;
%title('Path');
%plot(xOverTime, yOverTime, 'b');
%plot(xOverTimeMG, yOverTimeMG, 'r');
%legend('Lidar', 'Mouse+Gyro');
%figure(5);
%title('RMSE');
%plot(lidar_times(2:end), rmseOvertime);

%fprintf('x: %f\n', xTransform);
%fprintf('y: %f\n', yTransform);
%fprintf('angle: %f\n', angleTransform);