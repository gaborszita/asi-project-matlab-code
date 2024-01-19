startEndTimes = get_start_end_times();
time1 = startEndTimes{1};
time2 = startEndTimes{2};

[mouse_gyro_times, xTransformMG, yTransformMG, angleTransformMG, ...
    xOverTimeMG, yOverTimeMG, angleOverTimeMG] = get_mouse_gyro_pos(time1, time2);

[lidar_times, xTransform, yTransform, angleTransform, ...
    xOverTime, yOverTime, angleOverTime, rmseOvertime] = lidar_icp_4(logfilename, time1, time2);

disp(length(lidar_times));

figure(1);
clf
hold on;
title('X');
plot(lidar_times, xOverTime, 'b');
plot(mouse_gyro_times, xOverTimeMG, 'r');
legend('Lidar', 'Mouse+Gyro');
figure(2);
clf
hold on;
title('Y');
plot(lidar_times, yOverTime, 'b');
plot(mouse_gyro_times, yOverTimeMG, 'r');
legend('Lidar', 'Mouse+Gyro');
figure(3);
clf
hold on;
title('Rotation');
grid on;
plot((lidar_times-0.009*10^10), angleOverTime, 'b');
plot(mouse_gyro_times, angleOverTimeMG, 'r');
figure(4);
clf
hold on;
title('Path');
plot(xOverTime, yOverTime, 'b');
plot(xOverTimeMG, yOverTimeMG, 'r');
legend('Lidar', 'Mouse+Gyro');
figure(5);
title('RMSE');
plot(lidar_times(2:end), rmseOvertime);

%fprintf('x: %f\n', xTransform);
%fprintf('y: %f\n', yTransform);
%fprintf('angle: %f\n', angleTransform);