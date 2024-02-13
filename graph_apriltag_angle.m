function [apriltag_times, xTransform, yTransform, angleTransform, xOverTime, yOverTime, angleOverTime] = graph_apriltag_angle(time1, time2, num)

[aprilTagTime, aprilTagData] = getAprilTagData(time1, time2);

%apriltag_times = zeros(length(aprilTagData), 1);
apriltag_times = [];
xTransform = 0;
yTransform = 0;
angleTransform = 0;
%xOverTime = zeros(length(aprilTagData), 1);
%yOverTime = zeros(length(aprilTagData), 1);
%angleOverTime = zeros(length(aprilTagData), 1);
xOverTime = [];
yOverTime = [];
angleOverTime = [];

idx = 1;

%length(aprilTagData)
splitIndexesStart = [];
splitIndexesEnd = [];

lastIdx = -1;
lastI = -1;
for i=1:length(aprilTagData)
    if (aprilTagData{i}(8) > 7*10^-7 && (aprilTagData{i}(7) == num))% && i>250 && i<300
        xOverTime(idx) = aprilTagData{i}(1);
        yOverTime(idx) = aprilTagData{i}(2);
        angleOverTime(idx) = aprilTagData{i}(6);
    
        xTransform = aprilTagData{i}(1);
        yTransform = aprilTagData{i}(2);
        angleTransform = aprilTagData{i}(6);
    
        apriltag_times(idx) = aprilTagTime{i};

      
        if lastI < i-10
            splitIndexesStart(end+1) = idx;
            if length(splitIndexesStart) > 1
                splitIndexesEnd(end+1) = lastIdx;
            end
        end

        lastIdx = idx;
        lastI = i;

        idx = idx + 1;
    end

    %if idx > 100
    %    break
    %end
end

splitIndexesEnd(end+1) = lastIdx;

if isempty(splitIndexesStart)
    splitIndexesStart(end+1) = 1;
end

hold on;
for i=1:length(splitIndexesEnd)
    startIdx = splitIndexesStart(i);
    endIdx = splitIndexesEnd(i);
    try
        plot(apriltag_times(startIdx:endIdx), rad2deg(getClosestAngles(angleOverTime(startIdx:endIdx), angleOverTime(1))), 'b');
    catch
        %keyboard
    end
end

%plot(apriltag_times(1:5), rad2deg(getClosestAngles(angleOverTime(1:5))), 'b');
%hold on;
%plot(apriltag_times(10:20), rad2deg(getClosestAngles(angleOverTime(10:20))), 'b');

end

function angles = getClosestAngles(angles, refAngle)

if nargin<2
    refAngle = angles(1);
end

for i=1:length(angles)
    angles(i) = getClosestAngle(refAngle, angles(i));
end

end

function angle = getClosestAngle(refAngle, angle)

while angle-refAngle>=pi
    angle = angle - 2*pi;
end

while angle-refAngle<-pi
    angle = angle + 2*pi;
end

end

function [aprilTagTime, aprilTagData] = getAprilTagData(time1, time2)
data = file_read_test();

time1 = str2double(time1);
time2 = str2double(time2); 

timeColumn = cellfun(@str2double, data(:, 1));
subsetIndex = (timeColumn >= time1) & (timeColumn <= time2);
data = data(subsetIndex, :);

filtered_array = data(strcmp(data(:, 2), 'AprilTag'), :);
rowsToKeep = 1:1:size(filtered_array, 1);
filtered_array = filtered_array(rowsToKeep, :);

decoded_data = cell(size(filtered_array, 1), 1);
aprilTagTime = cell(size(filtered_array, 1), 1);

for i = 1:size(filtered_array, 1)
    csv_string = filtered_array{i, 3};  % Get the CSV string from the third column
    decoded_values = textscan(csv_string, '%f', 'Delimiter', ',');  % Decode CSV
    decoded_data{i} = decoded_values{1};  % Store the decoded values
    
    aprilTagTime{i} = str2double(filtered_array{i, 1});
end

% Extract the lidar data within the specified time range
aprilTagData = decoded_data;

end