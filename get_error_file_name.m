function error_file_name = get_error_file_name(log_file_name)
% Specify the original file name with the current extension
originalFileName = log_file_name;

% Define the new extension you want (in this case, '.txt')
newExtension = '.csv';

% Use the fileparts function to separate the file name and extension
[~, fileName, ~] = fileparts(originalFileName);

% Create the new file name with the desired extension
newFileName = [fileName, newExtension];

% Combine the path and new file name to get the full file path with the new extension
newFilePath = fullfile('errors', newFileName);

error_file_name = newFilePath;
end

