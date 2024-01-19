function [mouse_gyro_times, xTransform, yTransform, angleTransform, xOverTime, yOverTime, angleOverTime] = get_mouse_gyro_pos(time1, time2)

[gyroTime, gyroData] = getGyroData(time1, time2);
[mouseTime, mouseData] = getMouseData(time1, time2);

mouse_gyro_times = zeros(length(gyroData)+length(mouseData), 1);
xTransform = 0;
yTransform = 0;
angleTransform = 0;
xOverTime = zeros(length(gyroData)+length(mouseData), 1);
yOverTime = zeros(length(gyroData)+length(mouseData), 1);
angleOverTime = zeros(length(gyroData)+length(mouseData), 1);

gyroIndex = 1;
mouseIndex = 1;

zeroAngle = gyroData{gyroIndex}(3);

arrayIdx = 1;

while gyroIndex <= length(gyroData) || mouseIndex <= length(mouseData)
   if mouseIndex > length(mouseData)
       [angleTransform] = processGyroData(zeroAngle, gyroData{gyroIndex});
       mouse_gyro_times(arrayIdx) = gyroTime{gyroIndex};
       gyroIndex = gyroIndex + 1;
   elseif gyroIndex > length(gyroData)
       [xTransform, yTransform] = processMouseData(xTransform, yTransform, angleTransform, mouseData{mouseIndex});
       mouse_gyro_times(arrayIdx) = mouseTime{mouseIndex};
       mouseIndex = mouseIndex + 1;
   elseif gyroTime{gyroIndex} < mouseTime{mouseIndex}
       [angleTransform] = processGyroData(zeroAngle, gyroData{gyroIndex});
       mouse_gyro_times(arrayIdx) = gyroTime{gyroIndex};
       gyroIndex = gyroIndex + 1;
   else
       [xTransform, yTransform] = processMouseData(xTransform, yTransform, angleTransform, mouseData{mouseIndex});
       mouse_gyro_times(arrayIdx) = mouseTime{mouseIndex};
       mouseIndex = mouseIndex + 1;
   end
   xOverTime(arrayIdx) = xTransform;
   yOverTime(arrayIdx) = yTransform;
   angleOverTime(arrayIdx) = angleTransform;
   arrayIdx = arrayIdx + 1;
end

end

function [newAngle] = processGyroData(zeroAngle, gyroData)

newAngle = gyroData(3) - zeroAngle;

end

function [newX, newY] = processMouseData(currX, currY, angleTransform, mouseData)

x = mouseData(4);
y = mouseData(3);

dist = sqrt(x^2+y^2);
angle = atan2(y, x);
%xTranslated = dist * cos(angle + eulerAnglesRad(1));
%yTranslated = dist * sin(angle + eulerAnglesRad(1));
xTranslated = dist * cos(angle + deg2rad(angleTransform));
yTranslated = dist * sin(angle + deg2rad(angleTransform));
% DELETE BELOW AFTER TESTING
%xTranslated = dist * cos(angle);
%yTranslated = dist * sin(angle);

newX = currX + xTranslated;
newY = currY + yTranslated;

end

function [gyroTime, gyroData] = getGyroData(time1, time2)
data = file_read_test();

time1 = str2double(time1);
time2 = str2double(time2); 

timeColumn = cellfun(@str2double, data(:, 1));
subsetIndex = (timeColumn >= time1) & (timeColumn <= time2);
data = data(subsetIndex, :);

filtered_array = data(strcmp(data(:, 2), 'Gyro'), :);
rowsToKeep = 1:1:size(filtered_array, 1);
filtered_array = filtered_array(rowsToKeep, :);

decoded_data = cell(size(filtered_array, 1), 1);
gyroTime = cell(size(filtered_array, 1), 1);

for i = 1:size(filtered_array, 1)
    csv_string = filtered_array{i, 3};  % Get the CSV string from the third column
    decoded_values = textscan(csv_string, '%f', 'Delimiter', ',');  % Decode CSV
    decoded_data{i} = decoded_values{1};  % Store the decoded values
    
    gyroTime{i} = str2double(filtered_array{i, 1});
end

% Extract the lidar data within the specified time range
gyroData = decoded_data;

end

function [mouseTime, mouseData] = getMouseData(time1, time2)
data = file_read_test();

time1 = str2double(time1);
time2 = str2double(time2); 

timeColumn = cellfun(@str2double, data(:, 1));
subsetIndex = (timeColumn >= time1) & (timeColumn <= time2);
data = data(subsetIndex, :);

filtered_array = data(strcmp(data(:, 2), 'Mouse'), :);
rowsToKeep = 1:1:size(filtered_array, 1);
filtered_array = filtered_array(rowsToKeep, :);

decoded_data = cell(size(filtered_array, 1), 1);
mouseTime = cell(size(filtered_array, 1), 1);

for i = 1:size(filtered_array, 1)
    csv_string = filtered_array{i, 3};  % Get the CSV string from the third column
    decoded_values = textscan(csv_string, '%f', 'Delimiter', ',');  % Decode CSV
    decoded_data{i} = decoded_values{1};  % Store the decoded values
    
    mouseTime{i} = str2double(filtered_array{i, 1});
end

% Extract the lidar data within the specified time range
mouseData = decoded_data;

end