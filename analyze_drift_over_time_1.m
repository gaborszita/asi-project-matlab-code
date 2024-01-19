xOverTimeAllRead = readcell("xovertimeall.csv");
yOverTimeAllRead = readcell("yovertimeall.csv");
angleOverTimeAllRead = readcell("angleovertimeall.csv");

xOverTimeAll = cell(size(xOverTimeAllRead, 1), 1);
for i=1:size(xOverTimeAllRead, 1)
    xOverTimeAll{i} = cell2mat(xOverTimeAllRead(i, cellfun(@isnumeric, xOverTimeAllRead(i, :))));
end

yOverTimeAll = cell(size(xOverTimeAllRead, 1), 1);
for i=1:size(xOverTimeAllRead, 1)
    yOverTimeAll{i} = cell2mat(yOverTimeAllRead(i, cellfun(@isnumeric, yOverTimeAllRead(i, :))));
end

angleOverTimeAll = cell(size(xOverTimeAllRead, 1), 1);
for i=1:size(xOverTimeAllRead, 1)
    angleOverTimeAll{i} = cell2mat(angleOverTimeAllRead(i, cellfun(@isnumeric, angleOverTimeAllRead(i, :))));
end

normalizedArraysLength = 1000;
normalizedXOverTimeAll = cell(size(xOverTimeAll, 1), normalizedArraysLength);
normalizedYOverTimeAll = cell(size(yOverTimeAll, 1), normalizedArraysLength);
normalizedAngleOverTimeAll = cell(size(angleOverTimeAll, 1), normalizedArraysLength);

for i=1:length(xOverTimeAll)
  for j=1:normalizedArraysLength
    normalizedXOverTimeAll{i, j} = xOverTimeAll{i}(ceil(j/normalizedArraysLength*length(xOverTimeAll{i})));
    normalizedYOverTimeAll{i, j} = yOverTimeAll{i}(ceil(j/normalizedArraysLength*length(yOverTimeAll{i})));
    normalizedAngleOverTimeAll{i, j} = angleOverTimeAll{i}(ceil(j/normalizedArraysLength*length(angleOverTimeAll{i})));
  end
end

driftXOverTimeAll = zeros(normalizedArraysLength, 3);
driftYOverTimeAll = zeros(normalizedArraysLength, 3);
driftAngleOverTimeAll = zeros(normalizedArraysLength, 3);

for i=1:normalizedArraysLength
  xData = cell2mat(normalizedXOverTimeAll(:, i));
  [low, mid, high] = calculate_bounds(xData);
  driftXOverTimeAll(i, :) = [low, mid, high];
  yData = cell2mat(normalizedYOverTimeAll(:, i));
  [low, mid, high] = calculate_bounds(yData);
  driftYOverTimeAll(i, :) = [low, mid, high];
  angleData = cell2mat(normalizedAngleOverTimeAll(:, i));
  [low, mid, high] = calculate_bounds(angleData);
  driftAngleOverTimeAll(i, :) = [low, mid, high];
end

figure(4);
clf
hold on;
title('Path');
%plot(xOverTime, yOverTime, 'b');
plot(driftXOverTimeAll(:, 1), driftYOverTimeAll(:, 1), 'r');
plot(driftXOverTimeAll(:, 2), driftYOverTimeAll(:, 2), 'g');
plot(driftXOverTimeAll(:, 3), driftYOverTimeAll(:, 3), 'b');
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

bound_percentile = 85;

mid = median(data);
low = prctile(data, 100-bound_percentile);
high = prctile(data, bound_percentile);

end