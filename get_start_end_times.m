function startEndTimes = get_start_end_times()

array_of_arrays = file_read_test;

% Filter the original array_of_arrays to keep rows with 'LineFollowerFSM' in the second column
filtered_rows = array_of_arrays(strcmp(array_of_arrays(:, 2), 'LineFollowerFSM'), :);

% Filter the filtered rows again to keep rows where the third column is 'Start' or 'End'
filtered_rows = filtered_rows(ismember(filtered_rows(:, 3), {'Start', 'End', 'PathEnd'}), :);

% Initialize variables
start_times = cell(size(filtered_rows, 1), 1);
end_times = cell(size(filtered_rows, 1), 1);

% Initialize a counter and a flag to keep track of the last "Start" time
pair_counter = 0;
last_start = [];

% Iterate through the cell array
for i = 1:size(filtered_rows, 1)
    if strcmp(filtered_rows{i, 3}, 'Start')
        % Check if the current row is a "Start" time
        last_start = filtered_rows{i, 1};
    elseif strcmp(filtered_rows{i, 3}, 'PathEnd') || strcmp(filtered_rows{i, 3}, 'End')
        % Check if the current row is a "PathEnd" or "End" time
        if ~isempty(last_start)
            % If there was a corresponding "Start" time, store both times
            pair_counter = pair_counter + 1;
            start_times{pair_counter} = last_start; % Store the "Start" time
            end_times{pair_counter} = filtered_rows{i, 1}; % Store the "PathEnd" or "End" time
            last_start = []; % Reset the flag
        end
    end
end

% Resize the cell arrays to remove unused cells
start_times = start_times(1:pair_counter);
end_times = end_times(1:pair_counter);

% Create the 17x2 cell array by combining start and end times
result = [start_times, end_times];

startEndTimes = result;

end