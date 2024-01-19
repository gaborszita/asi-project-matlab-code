data = file_read_test;

filtered_array = data(strcmp(data(:, 2), 'RPLidar'), :);

% Initialize an empty cell array to store the decoded CSV data
decoded_data = cell(size(filtered_array, 1), 1);

% Loop through each row of the filtered array and decode the CSV data
for i = 1:size(filtered_array, 1)
    csv_string = filtered_array{i, 3};  % Get the CSV string from the third column
    decoded_values = textscan(csv_string, '%f', 'Delimiter', ',');  % Decode CSV
    decoded_data{i} = decoded_values{1};  % Store the decoded values
end

% Display the decoded data (cell array of arrays)
%disp(decoded_data{1});

%for i = 1:length(decoded_data)
%    % Get the array from the cell
%    decoded_array = decoded_data{i};
%
%    % Loop through the elements in the array and display them
%    for j = 1:length(decoded_array)
%        fprintf('Element %d of cell %d: %.2f\n', j, i, decoded_array(j));
%    end
%end

%disp(filtered_array[3]);

xTransform = 0;
yTransform = 0;

data = decoded_data{1};
ptCloud1 = createPointCloud(data);
ptCloud2 = createPointCloud(decoded_data{812});
%pcshow(ptCloud1);
tForm = pcregistericp(ptCloud1, ptCloud2);
%disp(tForm.Translation);


for i=2:length(decoded_data)
    data1 = decoded_data{i-1};
    data2 = decoded_data{i};

    ptCloud1 = createPointCloud(data1);
    ptCloud2 = createPointCloud(data2);

    tForm = pcregistericp(ptCloud1, ptCloud2);
    x = tForm.Translation(1);
    y = tForm.Translation(2);

    xTransform = xTransform + x;
    yTransform = yTransform + y;
end

disp(xTransform);
disp(yTransform);




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
        xyzPoints(pointIdx, :) = [x, y, z];

        % Move the data index forward by 4 (3 for values, 1 for the flag)
        dataIdx = dataIdx + 4;

        % Increment the point index
        pointIdx = pointIdx + 1;
    else
        % If quality is 0, skip this point and move the data index forward by 4
        pointIdx = pointIdx + 1;
        dataIdx = dataIdx + 4;
    end
end

% Now, xyzPoints contains your point cloud data

ptCloud = pointCloud(xyzPoints);

end