%A = [1.1269   -0.4940    0.1129 
%     1.0000         0         0 
%          0    1.0000         0];

%B = [-0.3832
%      0.5919
%      0.5191];

%C = [1 0 0];

%D = 0;
%C = [1 0];

%A = [1.0    0.0
%     0.0    1.0];
%B = [1.0    0.0
%     0.0    1.0];
%C = [1.0    0.0
%     0.0    1.0];

clear file_read_test;
logfilename = './apriltag-logs/path_54_23_12_13_03_36_24.log';
file_read_test(logfilename);
%file_read_test();

startEndTimes = get_start_end_times();
time1 = startEndTimes{1};
time2 = startEndTimes{2};

[lidar_times, xTransform, yTransform, angleTransform, ...
        xOverTime, yOverTime, angleOverTime, ~, xvals, yvals] = lidar_icp_7(logfilename, time1, time2);

lidaricppos = [lidar_times; xOverTime'; yOverTime'; angleOverTime'];

[apriltag_times, xTransformAprilTag, yTransformAprilTag, angleTransformAprilTag, ...
    xOverTimeAprilTag, yOverTimeAprilTag, angleOverTimeAprilTag] = get_apriltag_pos(time1, time2);

apriltagpos = [apriltag_times; xOverTimeAprilTag; yOverTimeAprilTag; angleOverTimeAprilTag];

poses = combine_poses(apriltagpos, lidaricppos);

writematrix(poses, 'out.csv');

A = 1;
B = 1;
C = 1;
D = 0;

Ts = -1;
sys = ss(A,[B B],C,D,Ts,'InputName',{'u' 'w'},'OutputName','y');

Q = 1.0;
R = 1000000000.0;

[kalmf,L,~,Mx,Z] = kalman(sys,Q,R);
kalmf = kalmf(1,:);

u = zeros(length(poses(:, 6)), 1);
for i=2:length(poses(:, 6))
    u(i) = poses(i, 6) - poses(i-1, 6);
end

%kalmf(1, 1, 1, 1, 1, 1)
[kalmanout1] = lsim(kalmf, [u poses(:, 2)]);

[kalmf,L,~,Mx,Z] = kalman(sys,Q,R);
kalmf = kalmf(1,:);

u = zeros(length(poses(:, 7)), 1);
for i=2:length(poses(:, 7))
    u(i) = poses(i, 7) - poses(i-1, 7);
end

%kalmf(1, 1, 1, 1, 1, 1)
[kalmanout2] = lsim(kalmf, [u poses(:, 3)]);

figure(1);
clf;
title('Path');
hold on;
plot(kalmanout1, kalmanout2, 'b');
legend('Lidar');

figure(2);
clf;
title('X');
hold on;
plot(poses(:, 1), poses(:, 2) - poses(1, 2), 'b');
plot(poses(:, 5), poses(:, 6) - poses(1, 6), 'r');
plot(poses(:, 1), kalmanout1 - kalmanout1(1), 'g');
legend('Apriltag', 'lidar icp', 'kalman');

figure(3);
clf;
title('Y');
hold on;
plot(poses(:, 1), poses(:, 3) - poses(1, 3), 'b');
plot(poses(:, 5), poses(:, 7) - poses(1, 7), 'r');
plot(poses(:, 1), kalmanout2 - kalmanout2(1), 'g');
legend('Apriltag', 'lidar icp', 'kalman');

figure(4);
clf;
title('Angle (rad)');
hold on;
sub = poses(1, 4);
sub = 0;
aprilTagAngs = setToClosestAng(poses(:, 4) - sub, deg2rad(poses(:, 8) - poses(1, 8)));
lidarAngs = deg2rad(poses(:, 8) - poses(1, 8));
plot(poses(:, 1), (rad2deg(aprilTagAngs)), 'b');
%plot(poses(:, 5), (rad2deg(lidarAngs)), 'r');
plot(lidar_times, angleOverTime, 'c');
[combinedTimes, combinedAngleOverTime] = combineAngles(lidar_times, deg2rad(angleOverTime), apriltag_times, aprilTagAngs);
plot(combinedTimes, rad2deg(combinedAngleOverTime), 'm');
legend('Apriltag', 'lidar icp');

[xOverTimeNew, yOverTimeNew] = recalcCoordsNewHeading(lidar_times, xvals, yvals, apriltag_times, angleOverTimeAprilTag);
figure(5);
clf;
title('Lidar with apriltag angle');
hold on;
plot(xOverTimeNew, yOverTimeNew, 'b');

[xOverTimeNew, yOverTimeNew] = recalcCoordsNewHeading(lidar_times, xvals, yvals, combinedTimes, combinedAngleOverTime);
figure(6);
clf;
title('Lidar with combined angle');
hold on;
plot(xOverTimeNew, yOverTimeNew, 'b');

figure(7);
clf;
title('Lidar only path');
hold on;
plot(xOverTime, yOverTime, 'b');

figure(8);
clf;
title('apriltag path');
hold on;
plot(xOverTimeAprilTag, yOverTimeAprilTag, 'b');

function [xOverTime, yOverTime] = recalcCoordsNewHeading(times, xvals, yvals, angleOverTimeTimes, angleOverTime)

xOverTime = zeros(length(xvals), 1);
yOverTime = zeros(length(yvals), 1);
xTransform = 0;
yTransform = 0;

for i=1:length(xvals)
    [~, angleOverTimeIdx] = min(abs(angleOverTimeTimes - times(i)));
    %angleOverTimeIdx
    angleTransform = angleOverTime(angleOverTimeIdx);

    x = xvals(i);
    y = yvals(i);

    dist = sqrt(x^2+y^2);
    angle = atan2(y, x);
    xTranslated = dist * cos(angleTransform-angle);
    yTranslated = dist * sin(angleTransform-angle);

    xTransform = xTransform + xTranslated;
    yTransform = yTransform + yTranslated;

    xOverTime(i) = xTransform;
    yOverTime(i) = yTransform;
end

end

function [times, angleOverTime] = combineAngles(freqTimes, freqAngleOverTime, accurateTimes, accurateAngleOverTime)

times = [];
angleOverTime = [];
accurateTimeIdx = 1;
accurateAngle = accurateAngleOverTime(accurateTimeIdx);
freqAngleRef = freqAngleOverTime(1);

for i=1:length(freqTimes)

    if accurateTimeIdx+1 <= length(accurateTimes) && freqTimes(i) >= accurateTimes(accurateTimeIdx+1)
        [~, accurateTimeIdx] = min(abs(accurateTimes - freqTimes(i)));
        accurateAngle = accurateAngleOverTime(accurateTimeIdx);
        freqAngleRef = freqAngleOverTime(i);
    end

    angle = freqAngleOverTime(i) - freqAngleRef + accurateAngle;
    times(i) = freqTimes(i);
    angleOverTime(i) = angle;

end

end

function array = clampDeg(array)

for i=1:length(array)
    while array(i)<0
        array(i) = array(i) + 360;
    end
    while array(i)>=360
        array(i) = array(i) - 360;
    end
end

end

function arrayToSet = setToClosestAng(arrayToSet, refArray)

for i=1:length(arrayToSet)
    while arrayToSet(i)-refArray(i)<=-pi
        arrayToSet(i) = arrayToSet(i) + 2*pi;
    end
    while arrayToSet(i)-refArray(i)>pi
        arrayToSet(i) = arrayToSet(i) - 2*pi;
    end
end

end

% apriltagpos - apriltags
% lidaricppos - lidar icp
function poses = combine_poses(apriltagpos, lidaricppos)

poses = [];
posesidx = 1;

    for i=1:size(apriltagpos, 2)
    
        [~, lidaricpidx] = min(abs(lidaricppos(1, :) - apriltagpos(1, i)));
        poses(posesidx, :) = [apriltagpos(:, i); lidaricppos(:, lidaricpidx)];

        posesidx = posesidx + 1;
    
    end

end