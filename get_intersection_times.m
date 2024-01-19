function intersectionTimes = get_intersection_times()

% Read the data from your source (file_read_test function or other source)
data = file_read_test();

% Filter the data to keep rows with 'LineFollowerFSM' in the second column
% and 'Intersection' in the third column
filtered_rows = (strcmp(data(:, 2), 'LineFollowerFSM') & strcmp(data(:, 3), 'Intersection'));

% Extract the first column (time values) for the filtered rows
intersectionTimes = cellfun(@str2double, data(filtered_rows, 1));

end