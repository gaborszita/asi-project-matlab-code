file_read_test(logfilename);

logfilename = './logs/path_2_23_11_19_06_54_36.log';
error_file_name = get_error_file_name(logfilename);

startEndTimes = get_start_end_times();
time1 = startEndTimes{1};
time2 = startEndTimes{2};

[lidar_times, xTransform, yTransform, angleTransform, ...
    xOverTime, yOverTime, angleOverTime, rmseOvertime] = lidar_icp_7(logfilename, time1, time2);

[lidar_time, decoded_data] = getLidarData(time1, time2);

%xOverTime = zeros(length(decoded_data), 1);
%yOverTime = zeros(length(decoded_data), 1);
%angleOverTime = zeros(length(decoded_data), 1);
%rmseOverTime = zeros(length(decoded_data)-1, 1);

[mouse_gyro_times, ~, ~, ~, ~, ~, angleOverTimeMG] = ...
    get_mouse_gyro_pos(num2str(lidar_time{1}), num2str(lidar_time{length(lidar_time)}));

xTransform = 0;
yTransform = 0;
angleTransform = 0;

fig = uifigure;
xLabel = uilabel(fig, 'Text', 'X: ', 'Position', [10, 160, 200, 22]);
yLabel = uilabel(fig, 'Text', 'Y: ', 'Position', [10, 140, 200, 22]);
headingLabel = uilabel(fig, 'Text', 'Heading: ', 'Position', [10, 120, 200, 22]);
gyroHeadingLabel = uilabel(fig, 'Text', 'Gyro Heading: ', 'Position', [10, 100, 200, 22]);
sld = uislider(fig, "ValueChangedFcn", @(src,event)updateGauge(src,event,decoded_data,xLabel,yLabel,headingLabel,gyroHeadingLabel,xOverTime,yOverTime,angleOverTime,angleOverTimeMG));

%plot(5, 5, 'g');

figure(12);
ptCloud = createPointCloud(decoded_data{1});
pcshow(ptCloud, ViewPlane='XY');

function updateGauge(src,event,decoded_data,xLabel,yLabel,headingLabel,gyroHeadingLabel,xOverTime,yOverTime,angleOverTime,angleOverTimeMG)
figure(12);
event.Value
idx = round(event.Value/100*length(decoded_data));
ptCloud = createPointCloud(decoded_data{idx});
pcshow(ptCloud, ViewPlane='XY');
xLabel.Text = strcat('X: ', num2str(xOverTime(idx)));
yLabel.Text = strcat('Y: ', num2str(yOverTime(idx)));
headingLabel.Text = strcat('Heading: ', num2str(angleOverTime(idx)));
gyroHeadingLabel.Text = strcat('Gyro Heading: ', num2str(angleOverTimeMG(round(event.Value/100*length(angleOverTimeMG)))));
end

function [lidarTime, lidarData] = getLidarData(time1, time2)

% Read the data from your source (file_read_test function or other source)
data = file_read_test();
%disp(data);
%disp(time1);

%%%%%%%

time1 = str2double(time1);  % Replace with your desired time1
time2 = str2double(time2); 
%disp(time1);

% Convert the first column values to numeric
timeColumn = cellfun(@str2double, data(:, 1));


% Create a logical index for the subset
subsetIndex = (timeColumn >= time1) & (timeColumn <= time2);

% Extract the subset of data
%timeSubset = timeColumn(subsetIndex, :);
data = data(subsetIndex, :);

%%%%%%%

% Filter the data to keep rows with 'RPLidar' in the second column
filtered_array = data(strcmp(data(:, 2), 'RPLidar'), :);
%filtered_array

%filtered_array = filtered_array{1:5:length(filtered_array)};

rowsToKeep = 1:1:size(filtered_array, 1);
filtered_array = filtered_array(rowsToKeep, :);

% Initialize an empty cell array to store the decoded CSV data
decoded_data = cell(size(filtered_array, 1), 1);
lidarTime = cell(size(filtered_array, 1), 1);

% Initialize an empty array to store the filtered time values
%lidarTime = [];

% Loop through each row of the filtered array and decode the CSV data
for i = 1:size(filtered_array, 1)
    csv_string = filtered_array{i, 3};  % Get the CSV string from the third column
    decoded_values = textscan(csv_string, '%f', 'Delimiter', ',');  % Decode CSV
    decoded_data{i} = decoded_values{1};  % Store the decoded values
    
    % Store the corresponding time value for the filtered data
    %lidarTime = [lidarTime; timeSubset(i)];
    lidarTime{i} = str2double(filtered_array{i, 1});
end

% Extract the lidar data within the specified time range
lidarData = decoded_data;

end

function ptCloud = createPointCloud(data)

% Sample input array
%data = [2, 1, 2, 3, 4, 1, 2, 3, 4];

% Extract node count
nodeCount = data(1);

% Initialize arrays to store point cloud data
xyzPoints = zeros(nodeCount, 3);

% Initialize indices for parsing the input data
dataIdx = 2; % Start after the node count
pointIdx = 1;
arrayIdx = 1;

validPointCnt = 0;
% Loop through the data and extract points
while pointIdx <= nodeCount
    %disp(dataIdx);
    %disp(pointIdx);
    %disp(nodeCount);
    % Extract distance, angle, quality, and flag values
    distance = data(dataIdx);
    angle = data(dataIdx + 1);
    quality = data(dataIdx + 2);

    % Check if quality is non-zero (i.e., it's not ignored)
    if quality ~= 0
        % Calculate x, y, and z coordinates (you can adjust this calculation as needed)
        x = distance * cosd(angle);
        y = distance * sind(angle);
        z = 0; % Assuming z-coordinate is 0, you can modify this if needed

        % Store the point in xyzPoints
        xyzPoints(arrayIdx, :) = [x, y, z];

        % Move the data index forward by 4 (3 for values, 1 for the flag)
        dataIdx = dataIdx + 4;

        % Increment the point index
        pointIdx = pointIdx + 1;

        validPointCnt = validPointCnt + 1;
        arrayIdx = arrayIdx + 1;
    else
        % If quality is 0, skip this point and move the data index forward by 4
        pointIdx = pointIdx + 1;
        dataIdx = dataIdx + 4;
    end
end

xyzPoints = xyzPoints(1:validPointCnt, :);
%disp(xyzPoints);

% Now, xyzPoints contains your point cloud data

ptCloud = pointCloud(xyzPoints);

end