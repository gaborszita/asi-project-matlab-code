logfilename = './logs/path_1_long_23_10_31_06_27_14.log';
error_file_name = get_error_file_name(logfilename);

file_read_test(logfilename);
file_read_test();

startEndTimes = get_start_end_times();
time1 = startEndTimes{62};
time2 = startEndTimes{63};

%[mouse_gyro_times, xTransformMG, yTransformMG, angleTransformMG, ...
%    xOverTimeMG, yOverTimeMG, angleOverTimeMG] = get_mouse_gyro_pos(time1, time2);

[lidar_times, xTransform, yTransform, angleTransform, ...
    xOverTime, yOverTime, angleOverTime, rmseOvertime] = lidar_icp_7(logfilename, time1, time2);

%[lidar_timesG, xTransformG, yTransformG, angleTransformG, ...
%    xOverTimeG, yOverTimeG, angleOverTimeG, rmseOvertimeG] = lidar_icp_8(logfilename, time1, time2);

disp(length(lidar_times));

% lidar times frequencies is get by substracting lidar time from previous lidar time
%lidar_times_periods = diff(lidar_times/10^9);
%figure(18);
%plot(1:length(lidar_times_periods), lidar_times_periods);

figure(1);
%clf
%hold on;
title('X');
grid on;
plot(lidar_times, xOverTime, 'b');
%plot(mouse_gyro_times, xOverTimeMG, 'r');
%legend('Lidar', 'Mouse+Gyro');
figure(2);
%clf
%hold on;
title('Y');
grid on;
plot(lidar_times, yOverTime, 'b');
%plot(mouse_gyro_times, yOverTimeMG, 'r');
%legend('Lidar', 'Mouse+Gyro');
figure(3);
%clf
%hold on;
title('Rotation');
grid on;
plot(lidar_times, angleOverTime, 'b');
%plot(mouse_gyro_times, angleOverTimeMG, 'r');
%figure(4);
%clf
%hold on;
figure(4);
title('Path');
%hold on;
plot(xOverTime, yOverTime, 'b');
%plot(xOverTimeG, yOverTimeG, 'r');
legend('Lidar');
%figure(5);
%title('RMSE');
%plot(lidar_times(2:end), rmseOvertime);

%fprintf('x: %f\n', xTransform);
%fprintf('y: %f\n', yTransform);
%fprintf('angle: %f\n', angleTransform);