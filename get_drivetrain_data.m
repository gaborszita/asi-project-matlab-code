function get_drivetrain_data(time1, time2)

data = file_read_test();

time1 = str2double(time1);
time2 = str2double(time2); 

timeColumn = cellfun(@str2double, data(:, 1));
subsetIndex = (timeColumn >= time1) & (timeColumn <= time2);
data = data(subsetIndex, :);

filtered_array = data(strcmp(data(:, 2), 'DriveTrain'), :);
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