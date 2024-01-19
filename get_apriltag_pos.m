function [apriltag_times, xTransform, yTransform, angleTransform, xOverTime, yOverTime, angleOverTime] = get_apriltag_pos(time1, time2)

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

length(aprilTagData)

for i=1:length(aprilTagData)
    aprilTagData{i}(7)
    if i < 20 || (aprilTagData{i}(8) > 7*10^-7 && (aprilTagData{i}(7) == 8 || (aprilTagData{i}(7) == 1 && i < 20)))% && i>250 && i<300
        disp('in')
        xOverTime(idx) = aprilTagData{i}(1);
        yOverTime(idx) = aprilTagData{i}(2);
        angleOverTime(idx) = aprilTagData{i}(6);
    
        xTransform = aprilTagData{i}(1);
        yTransform = aprilTagData{i}(2);
        angleTransform = aprilTagData{i}(6);
    
        apriltag_times(idx) = aprilTagTime{i};

        idx = idx + 1;
    end

    %if idx > 100
    %    break
    %end
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