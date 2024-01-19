[name, rep, path] = read_path('paths/23_11_25_11_47_27_path_30.txt');

verify_path(path)

%path = generate_random_path(30);

%verify_path(path)

%write_path('paths/path_3.csv', 'path_3', 50, path);