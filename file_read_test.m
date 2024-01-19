function ret = file_read_test(filename_arg)

persistent filename
persistent filedata

if isempty(filename)
    filename = filename_arg;
end

if isempty(filedata)
    % Read the CSV file
    fid = fopen(filename, 'r');
    data = textscan(fid, '"%[^"]","%[^"]","%[^"]"', 'Delimiter', ',');
    fclose(fid);
    
    % Convert the cell arrays to arrays of strings
    col1 = data{1};
    col2 = data{2};
    col3 = data{3};
    
    % Create an array of arrays with a size of 3 for each inner array
    filedata = [col1, col2, col3];
end

ret=filedata;