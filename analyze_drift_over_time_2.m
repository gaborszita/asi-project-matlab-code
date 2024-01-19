xOverTimeAllRead = readcell("xovertimeall.csv");
yOverTimeAllRead = readcell("yovertimeall.csv");
angleOverTimeAllRead = readcell("angleovertimeall.csv");
lidarTimesAllRead = readcell("lidartimesall.csv");

xOverTimeAll = cell(size(xOverTimeAllRead, 1), 1);
for k=1:size(xOverTimeAllRead, 1)
    xOverTimeAll{k} = cell2mat(xOverTimeAllRead(k, cellfun(@isnumeric, xOverTimeAllRead(k, :))));
end

yOverTimeAll = cell(size(xOverTimeAllRead, 1), 1);
for k=1:size(xOverTimeAllRead, 1)
    yOverTimeAll{k} = cell2mat(yOverTimeAllRead(k, cellfun(@isnumeric, yOverTimeAllRead(k, :))));
end

angleOverTimeAll = cell(size(xOverTimeAllRead, 1), 1);
for k=1:size(xOverTimeAllRead, 1)
    angleOverTimeAll{k} = cell2mat(angleOverTimeAllRead(k, cellfun(@isnumeric, angleOverTimeAllRead(k, :))));
end

lidarTimesAll = cell(size(xOverTimeAllRead, 1), 1);
for k=1:size(xOverTimeAllRead, 1)
    lidarTimesAll{k} = cell2mat(lidarTimesAll(k, cellfun(@isnumeric, lidarTimesAllRead(k, :))));
end

normalizedArraysLength = 300;
normalizedXOverTimeAll = cell(size(xOverTimeAll, 1), normalizedArraysLength);
normalizedYOverTimeAll = cell(size(yOverTimeAll, 1), normalizedArraysLength);
normalizedAngleOverTimeAll = cell(size(angleOverTimeAll, 1), normalizedArraysLength);

for k=1:length(xOverTimeAll)
  currrentRunIntersectionTimes = lidarTimesAll((lidarTimesAll > lidarTimesAll{k}(1)) & (lidarTimesAll < lidarTimesAll{k}(end)));
  for m=1:length(currentRunIntersectionTimes)
    for l=m/length(currentRunIntersectionTimes):(m+1)/length(currentRunIntersectionTimes)
    for l=1:normalizedArraysLength
      normalizedXOverTimeAll{k, l} = xOverTimeAll{k}(ceil(l/normalizedArraysLength*length(xOverTimeAll{k})));
      normalizedYOverTimeAll{k, l} = yOverTimeAll{k}(ceil(l/normalizedArraysLength*length(yOverTimeAll{k})));
      normalizedAngleOverTimeAll{k, l} = angleOverTimeAll{k}(ceil(l/normalizedArraysLength*length(angleOverTimeAll{k})));
    end
  end
end

driftXOverTimeAll = zeros(normalizedArraysLength, 3);
driftYOverTimeAll = zeros(normalizedArraysLength, 3);
driftAngleOverTimeAll = zeros(normalizedArraysLength, 3);

prevxmid = 0;
prevymid = 0;
for k=1:normalizedArraysLength
  xData = cell2mat(normalizedXOverTimeAll(:, k));
  yData = cell2mat(normalizedYOverTimeAll(:, k));
  angleData = cell2mat(normalizedAngleOverTimeAll(:, k));
  [xlow, xmid, xhigh, ylow, ymid, yhigh] = calculate_bounds_2(xData, yData, angleData, prevxmid, prevymid);
  driftXOverTimeAll(k, :) = [xlow, xmid, xhigh];
  driftYOverTimeAll(k, :) = [ylow, ymid, yhigh];
  prevxmid = xmid;
  prevymid = ymid;
  [low, mid, high] = calculate_bounds(xData);
  driftXOverTimeAll(k, :) = [low, mid, high];
  [low, mid, high] = calculate_bounds(yData);
  driftYOverTimeAll(k, :) = [low, mid, high];
  angleData = cell2mat(normalizedAngleOverTimeAll(:, k));
  [low, mid, high] = calculate_bounds(angleData);
  driftAngleOverTimeAll(k, :) = [low, mid, high];
end

figure(4);
clf
hold on;
title('Path');
%plot(xOverTime, yOverTime, 'b');
plot3(driftXOverTimeAll(:, 1), driftYOverTimeAll(:, 1), zeros(length(driftYOverTimeAll(:, 1)), 1), 'r');
plot3(driftXOverTimeAll(:, 2), driftYOverTimeAll(:, 2), zeros(length(driftYOverTimeAll(:, 1)), 1), 'g');
plot3(driftXOverTimeAll(:, 3), driftYOverTimeAll(:, 3), zeros(length(driftYOverTimeAll(:, 1)), 1), 'b');

figure(5);
clf
hold on;
title('Path drift');
zVal = 0;
r = 0;
g = 0;
b = 0;
colorLimit = 180;
zValInc = 0.01;
for k=1:5:length(driftYOverTimeAll(:, 1))-2

    x = driftXOverTimeAll(k, :);
    xNext = driftXOverTimeAll(k+1, :);
    xNextNext = driftXOverTimeAll(k+2, :);
    y = driftYOverTimeAll(k, :);
    yNext = driftYOverTimeAll(k+1, :);
    yNextNext = driftYOverTimeAll(k+2, :);
    directionVector = [x(3)-x(1), y(3)-y(1)];
    heading = angle(directionVector(1)+1i*directionVector(2));
    directionVectorNext = [xNext(3)-xNext(1), yNext(3)-yNext(1)];
    headingNext = angle(directionVectorNext(1)+1i*directionVectorNext(2));
    %x(3)

    rot = driftAngleOverTimeAll(k+1, :);
    rot(2);
    [coords1, ~] = ellipse3D((x(3)-x(1))/2, (y(3)-y(1))/2, x(2), y(2), zVal, 25, deg2rad(0), 0, deg2rad(0), 0);
    plot3(coords1(1, :), coords1(2, :), coords1(3, :), 'color', [r/255 g/255 b/255]);
    rot = driftAngleOverTimeAll(k+2, :);
    rot(2);
    [coords2, ~] = ellipse3D((xNext(3)-xNext(1))/2, (yNext(3)-yNext(1))/2, xNext(2), yNext(2), zVal+zValInc, 25, pi/2, deg2rad(0), deg2rad(0), 0);
    t = [coords1(1, :); coords2(1, :)];
    u = [coords1(2, :); coords2(2, :)];
    v = [coords1(3, :); coords2(3, :)];
    %surf(t, u, v);
    %k
    %r
    %g
    %b
    if r < colorLimit
        r = r + 3;
    elseif g < colorLimit
        g = g + 3;
    elseif b < colorLimit
        b = b + 3;
    else
        r = 0;
        g = 0;
        b = 0;
    end
    zVal = zVal + zValInc;
end
%x = cell2mat(xOverTimeAll(1, :));
%x = 1:length(cell2mat(yOverTimeAll(1, :)));
%y = cell2mat(yOverTimeAll(1, :));
%plot(x, y, 'r');
%x = 1:length(cell2mat(xOverTimeAll(1, :)));
%y = cell2mat(xOverTimeAll(1, :));
%figure(5);
%clf
%plot(x, y, 'b');
legend('Lidar');

function [low, mid, high] = calculate_bounds(data)

bound_percentile = 95;

mid = median(data);
low = prctile(data, 100-bound_percentile);
high = prctile(data, bound_percentile);

end

function [xlow, xmid, xhigh, ylow, ymid, yhigh] = calculate_bounds_2(xdata, ydata, angleData, prevxmid, prevymid)

xmid = median(xdata);
ymid = median(ydata);

bound_percentile = 90;

%rotationAngle = -atan2(ymid - prevymid, xmid - prevxmid);
rotationAngle = -deg2rad(mean(angleData));
mean(angleData)
%rotationAngle = 0;
R = [cos(rotationAngle), -sin(rotationAngle); sin(rotationAngle), cos(rotationAngle)];
coords = [xdata, ydata];
rotated_coords = R * coords';
xlow_rotated = prctile(rotated_coords(1, :), 100-bound_percentile);
[~, indexLow] = min(abs(rotated_coords(1, :) - xlow_rotated));
xhigh_rotated = prctile(rotated_coords(1, :), bound_percentile);
[~, indexHigh] = min(abs(rotated_coords(1, :) - xhigh_rotated));
%xlow = xdata(indexLow);
%ylow = ydata(indexLow);
%xhigh = xdata(indexHigh);
%yhigh = ydata(indexHigh);
ylow_rotated = prctile(rotated_coords(2, :), 100-bound_percentile);
yhigh_rotated = prctile(rotated_coords(2, :), bound_percentile);

%rotationAngle = 0;
Rback = [cos(-rotationAngle), -sin(-rotationAngle); sin(-rotationAngle), cos(-rotationAngle)];
low_rot_back = Rback * [xlow_rotated; ylow_rotated];
xlow = low_rot_back(1);
ylow = low_rot_back(2);
high_rot_back = Rback * [xhigh_rotated; yhigh_rotated];
xhigh = high_rot_back(1);
yhigh = high_rot_back(2);

end

function plot_circle(x0, y0, a, b)
t=-pi:0.5:pi;
x=x0+a*cos(t);
y=y0+b*sin(t);
plot3(x,y,zeros(length(x)));
end