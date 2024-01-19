function [name, rep, path] = read_path(file)
    data = readcell(file);
    name = data{1};
    rep = data{2};
    path = data(3:end);
end