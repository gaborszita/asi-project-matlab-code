%logfilename = './logs/path_3_23_12_10_01_01_15.log';
clear file_read_test;
logfilename = './apriltag-logs/path_54_23_12_13_03_36_24.log';
error_file_name = get_error_file_name(logfilename);

file_read_test(logfilename);
file_read_test();

startEndTimes = get_start_end_times();
time1 = startEndTimes{5};
time2 = startEndTimes{6};

[apriltag_times, xTransform, yTransform, angleTransform, ...
    xOverTime, yOverTime, angleOverTime] = get_apriltag_pos(time1, time2);

step = 5;
xOverTimeAvg = zeros(ceil(length(xOverTime)/step), 1);
yOverTimeAvg = zeros(ceil(length(xOverTime)/step), 1);

for i=1:length(xOverTime)

    xOverTimeAvg(ceil(i/step)) = xOverTimeAvg(ceil(i/step)) + xOverTime(i);
    yOverTimeAvg(ceil(i/step)) = yOverTimeAvg(ceil(i/step)) + yOverTime(i);

end

xOverTimeAvg = xOverTimeAvg / step;
yOverTimeAvg = yOverTimeAvg / step;

figure(1);
clf
hold on;
title('Path');
%colors = ['g', 'b', 'r', 'c', 'm', 'y', 'k'];
%shards = 7;
%for i=1:shards
%    plot(xOverTimeAvg(1+(i-1)*length(xOverTimeAvg)/shards:i*length(xOverTimeAvg)/shards), ...
%        yOverTimeAvg(1+(i-1)*length(yOverTimeAvg)/shards:i*length(yOverTimeAvg)/shards), ...
%        colors(i));
%end
plot(xOverTimeAvg(1:end), yOverTimeAvg(1:end), 'r');
%for i=1:step:length(xOverTimeAvg)
%    plot(xOverTimeAvg(i), yOverTimeAvg(i), 'b');
%end
%plot(xOverTimeAvg, yOverTimeAvg, 'b');
legend('AprilTag');