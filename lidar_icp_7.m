function [lidar_times, xTransform, yTransform, angleTransform, xOverTime, yOverTime, angleOverTime, rmseOverTime, xvals, yvals] = lidar_icp_7(logfilename, time1, time2)

file_read_test(logfilename);

[lidar_time, decoded_data] = getLidarData(time1, time2);

xOverTime = zeros(length(decoded_data), 1);
yOverTime = zeros(length(decoded_data), 1);
angleOverTime = zeros(length(decoded_data), 1);
rmseOverTime = zeros(length(decoded_data)-1, 1);
xvals = zeros(length(decoded_data)-1, 1);
yvals = zeros(length(decoded_data)-1, 1);

xTransform = 0;
yTransform = 0;
angleTransform = 0;

[mouse_gyro_times, ~, ~, ~, ~, ~, angleOverTimeMG] = ...
    get_mouse_gyro_pos(num2str(lidar_time{1}), num2str(lidar_time{length(lidar_time)}));


for i=2:1:length(decoded_data)

    data1 = decoded_data{i-1};
    data2 = decoded_data{i};

    ptCloud1 = createPointCloud(data1);
    ptCloud2 = createPointCloud(data2);

    gyroAngleTransform = getGyroAngleAtTime(lidar_time{i}, mouse_gyro_times, angleOverTimeMG);
    gyroAngleTransformBefore = getGyroAngleAtTime(lidar_time{i-1}, mouse_gyro_times, angleOverTimeMG);

    %if gyroAngleTransform < -170 && gyroAngleTransform > -190
    %    gyroAngleTransform = -178;
    %end

    deltaGyroAngle = gyroAngleTransform - gyroAngleTransformBefore;
    deltaGyroAngleAngleRadians = deg2rad(deltaGyroAngle);
    rot = deg2rad(0);

    rotationMatrix = [cos(rot), -sin(rot), 0, 0;
                       sin(rot), cos(rot), 0, 0;
                       0, 0, 1, 0;
                       0, 0, 0, 1];
    
    rigidTransformInitial = rigid3d(rotationMatrix);

    [tform, ~, rmse] = pcregistericp(ptCloud1, ptCloud2, MaxIterations=100000,Tolerance=[0.00001, 0.00001]);
    rot = tform.R;
    eulerAnglesRad = rotm2eul(rot);
    eulerAnglesDeg = rad2deg(eulerAnglesRad);
    angleTransform = angleTransform + eulerAnglesDeg(1);

    x = tform.Translation(1);
    y = tform.Translation(2);

    dist = sqrt(x^2+y^2);
    angle = atan2(y, x);
    xTranslated = dist * cos(deg2rad(angleTransform)-angle);
    yTranslated = dist * sin(deg2rad(angleTransform)-angle);

    %angleTransform = angleTransform + eulerAnglesDeg(1);

    %if lidar_time{i} > 1.2*10^10
    %    keyboard
    %end

    %rad2deg(angle + deg2rad(angleTransform))

    xTransform = xTransform + xTranslated;
    xOverTime(i) = xTransform;
    yTransform = yTransform + yTranslated;
    yOverTime(i) = yTransform;
    xvals(i) = x;
    yvals(i) = y;
    
    angleOverTime(i) = angleTransform;

    rmseOverTime(i-1) = rmse;

    %if xTransform > -0.04 && xTransform < -0.03 && yTransform > -0.79 && yTransform < -0.78
    %    keyboard
    %end
    %if xTransform > 0.52 && xTransform < 0.53 && yTransform > -0.67 && yTransform < -0.66
        %keyboard
    %end
    if xTransform > 0.55 && xTransform < 0.56 && yTransform < -0.49 && yTransform > -0.50
        %keyboard
        %angleTransform = angleTransform - 13;
    end
    %if xTransform > 0.29 && xTransform < 0.30 && yTransform < -0.71 && yTransform > -0.72
    %    keyboard
    %end
    if xTransform > 0.69 && xTransform < 0.70 && yTransform < -0.19 && yTransform > -0.20
        %keyboard
        %figure
        %pcshow(ptCloud1);
    end
    if xTransform > 0.57 && xTransform < 0.58 && yTransform < -0.36 && yTransform > -0.37
        %keyboard
        %figure
        %pcshow(ptCloud1);
    end
    if xTransform > 0.46 && xTransform < 0.47 && yTransform > -0.03 && yTransform < -0.02
        %keyboard
        %figure
        %pcshow(ptCloud1);
    end
end

%fprintf('total x transform: %f\n', xTransform);
%fprintf('total y transform: %f\n', yTransform);

lidar_time_numarray = zeros(1, length(lidar_time));

for i=1:length(lidar_time)
    lidar_time_numarray(i) = lidar_time{i};
end

lidar_times = lidar_time_numarray;

end

function gyroAngle = getGyroAngleAtTime(time, mouse_gyro_times, angleOverTimeMG)

diffs = abs(mouse_gyro_times - time);
idx = find(diffs == min(diffs));

gyroAngle = angleOverTimeMG(idx(1));

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