close all;

%decoded_data = getLidarData();

%format long g;
startEndTimes = getStartEndTimes();

%decoded_data = getLidarData(startEndTimes{1}, startEndTimes{2});
%for i=1:length(startEndTimes)-1
%    calculateIcp(startEndTimes{i}, startEndTimes{i+1});
%end
calculateIcp(startEndTimes{1}, startEndTimes{2});

%figure(3);
%figure(4);

% Display the result
%disp(startEndTimes);
%disp('hey');

function calculateIcp(time1, time2)

[lidar_time, decoded_data] = getLidarData(time1, time2);
intersection_times = getIntersectionTimes();
%disp(length(lidar_time));
%disp(length(decoded_data));
%intersection_times
%lidar_time

%figure(1);
ptCloud1 = createPointCloud(decoded_data{39}); % magenta
%pcshow(ptCloud1);
ptCloud2 = createPointCloud(decoded_data{40}); % green
%rx = 0;
%ry = 0;
%rz = 0;
% Rx = [1 0 0; 0 cosd(rx) -sind(rx); 0 sind(rx) cosd(rx)];
% Ry = [cosd(ry) 0 sind(ry); 0 1 0; -sind(ry) 0 cosd(ry)];
% Rz = [cosd(rz) -sind(rz) 0; sind(rz) cosd(rz) 0; 0 0 1];
%  R = Rz*Ry*Rx;
%tForm = rigidtform3d([0 0 -7], [0 0 0]);
% Transform the point cloud
%ptCloud1Trans = pctransform(ptCloud1, tForm);

%pcshowpair(ptCloud1Trans, ptCloud2);
tForm = pcregistericp(ptCloud1, ptCloud2); % moving, fixed
x = tForm.Translation(1);
y = tForm.Translation(2);
fprintf('x: %f\n', x);
fprintf('y: %f\n', y);
rot = tForm.R;
eulerAnglesRad = rotm2eul(rot);
eulerAnglesDeg = rad2deg(eulerAnglesRad);
disp('euler angles rot: ');
disp(eulerAnglesDeg(1));
figure(3);
ptCloud1Trans = pctransform(ptCloud1, tForm);
pcshowpair(ptCloud1, ptCloud2);
figure(4)
pcshowpair(ptCloud1Trans, ptCloud2);


%figure(1);
ptCloud1 = createPointCloud(decoded_data{41}); % magenta
ptCloud2 = createPointCloud(decoded_data{42}); % green
tForm = pcregistericp(ptCloud1, ptCloud2); % moving, fixed
x = tForm.Translation(1);
y = tForm.Translation(2);
fprintf('x: %f\n', x);
fprintf('y: %f\n', y);
rot = tForm.R;
eulerAnglesRad = rotm2eul(rot);
eulerAnglesDeg = rad2deg(eulerAnglesRad);
disp('euler angles rot: ');
disp(eulerAnglesDeg(1));
figure(13);
ptCloud1Trans = pctransform(ptCloud1, tForm);
pcshowpair(ptCloud1, ptCloud2);
figure(14)
pcshowpair(ptCloud1Trans, ptCloud2);

%return;

xOverTime = zeros(length(decoded_data), 1);
yOverTime = zeros(length(decoded_data), 1);
angleOverTime = zeros(length(decoded_data), 1);

xTransform = 0;
yTransform = 0;
angleTransform = 0;


for i=2:1:length(decoded_data)

    data1 = decoded_data{i-1};
    data2 = decoded_data{i};

    ptCloud1 = createPointCloud(data1);
    ptCloud2 = createPointCloud(data2);

    tForm = pcregistericp(ptCloud1, ptCloud2);
    rot = tForm.R;
    eulerAnglesRad = rotm2eul(rot);
    eulerAnglesDeg = rad2deg(eulerAnglesRad);
    angleTransform = angleTransform + eulerAnglesDeg(1);

    x = tForm.Translation(1);
    y = tForm.Translation(2);

    dist = sqrt(x^2+y^2);
    angle = atan(y/x);
    %xTranslated = dist * cos(angle + eulerAnglesRad(1));
    %yTranslated = dist * sin(angle + eulerAnglesRad(1));
    xTranslated = dist * cos(angle + rad2deg(angleTransform));
    yTranslated = dist * sin(angle + rad2deg(angleTransform));

    xTransform = xTransform + xTranslated;
    xOverTime(i) = xTransform;
    yTransform = yTransform + yTranslated;
    yOverTime(i) = yTransform;
    
    %disp('yes')
    %eulerAnglesDeg;
    %disp(eulerAnglesDeg);
    angleOverTime(i) = angleTransform;

    startTime = lidar_time{i-1};
    endTime = lidar_time{i};
    %disp('st');
    %startTime
    %disp('et');
    %endTime
    %disp(intersection_times);
    %startTime = 9896539223;
    %endTime = 10040560300;
    %intersection_times_arr = cell2mat(intersection_times);
    %comparison_result = cellfun(@(x) x >= startTime & x <= endTime, intersection_times);
    if max((intersection_times >= startTime) .* (intersection_times <= endTime)) ~= 0
    %if any(intersection_times >= startTime & intersection_times <= endTime)
        %figure(6);
        %hold on;
        %plot([i, i], [-0.4, 0.4], 'r', 'LineWidth', 2);
        %plot(i, 1, '*');
        %hold off;
        %disp('yeah');
    end
end

fprintf('total x transform: %f\n', xTransform);
fprintf('total y transform: %f\n', yTransform);
%disp(xTransform);
%disp(yTransform);

%lidar_time{3}

lidar_time_numarray = zeros(1, length(lidar_time));

for i=1:length(lidar_time)
    lidar_time_numarray(i) = lidar_time{i};
end

hold on;
figure(5);
%plot([xOverTime, yOverTime]);
plot(lidar_time_numarray, xOverTime);
hold on;
figure(6);
plot(lidar_time_numarray, yOverTime);
hold on;
figure(7);
plot(lidar_time_numarray, angleOverTime);
%plot(angleOverTime, 'g');
hold off;

end

function startEndTimes = getStartEndTimes()

array_of_arrays = file_read_test;

% Filter the original array_of_arrays to keep rows with 'LineFollowerFSM' in the second column
filtered_rows = array_of_arrays(strcmp(array_of_arrays(:, 2), 'LineFollowerFSM'), :);

% Filter the filtered rows again to keep rows where the third column is 'Start' or 'End'
filtered_rows = filtered_rows(ismember(filtered_rows(:, 3), {'Start', 'End'}), :);

% Extract the first column of the filtered rows
first_column_values = filtered_rows(:, 1);

startEndTimes = first_column_values;

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


function intersectionTimes = getIntersectionTimes()

% Read the data from your source (file_read_test function or other source)
data = file_read_test();

% Filter the data to keep rows with 'LineFollowerFSM' in the second column
% and 'Intersection' in the third column
filtered_rows = (strcmp(data(:, 2), 'LineFollowerFSM') & strcmp(data(:, 3), 'Intersection'));

% Extract the first column (time values) for the filtered rows
intersectionTimes = cellfun(@str2double, data(filtered_rows, 1));

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
    if quality ~= 0 && distance < 2 && distance>0.1
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