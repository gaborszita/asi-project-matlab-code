preferred_path_length = 15;
max_path_length = 15;
num_paths_to_generate = 10;
path_name_start_num = 50;
pathrep = 10;

%%%
generated_path_cnt = 0;
path_name_num = path_name_start_num;
datenowstr = string(datetime('now', 'Format', 'yy_MM_dd_HH_mm_ss'));

while generated_path_cnt < num_paths_to_generate

    path = generate_random_path(preferred_path_length);
    if ~verify_path(path)
        disp('ERROR: Path verification failed!');
    elseif length(path)<=max_path_length
        path_name = strcat('path_', num2str(path_name_num));
        filename = strcat('paths/', datenowstr, '_', path_name);
        write_path(filename, path_name, pathrep, path);
        generated_path_cnt = generated_path_cnt + 1;
        path_name_num = path_name_num + 1;
    end

end