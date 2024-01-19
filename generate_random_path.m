function path = generate_random_path(preferred_length)

field = get_field();
start_intersection = 1;

path = cell(preferred_length, 1);
intersection_num = start_intersection;

rng("shuffle");

for i=1:preferred_length
    current_intersection = field(intersection_num, :);
    numNonZeros = countNumNonZeros(current_intersection);
    nextIdx = randi(numNonZeros);
    for k=1:length(current_intersection)
        if k > nextIdx
            break
        end
        if current_intersection(k) == 0
            nextIdx = nextIdx + 1;
        end
    end
    if nextIdx == 1
        path{i} = 'Straight';
    elseif nextIdx == 2
        path{i} = 'Left';
    else
        path{i} = 'Right';
    end
    intersection_num = current_intersection(nextIdx);
end

[~, back_to_start_path_route] = dijkstra(generate_adjacency_matrix(field), intersection_num, start_intersection);
back_to_start_path_route = flip(back_to_start_path_route);
back_to_start_path = cell(length(back_to_start_path_route)-1, 1);

for i=2:length(back_to_start_path_route)
    current_intersection = field(intersection_num, :);
    if field(intersection_num, 1) == back_to_start_path_route(i)
        back_to_start_path{i-1} = 'Straight';
        nextIdx = 1;
    elseif field(intersection_num, 2) == back_to_start_path_route(i)
        back_to_start_path{i-1} = 'Left';
        nextIdx = 2;
    else
        back_to_start_path{i-1} = 'Right';
        nextIdx = 3;
    end
    intersection_num = current_intersection(nextIdx);
end

path = [path; back_to_start_path];

end

function count = countNumNonZeros(array)

count = 0;
for i=1:length(array)
    if array(i) ~= 0
        count = count + 1;
    end
end

end

function adjancency_matrix = generate_adjacency_matrix(field)

adjancency_matrix = zeros(length(field), length(field));

for i=1:length(field)
    for k=1:length(field(1, :))
        if field(i, k) ~= 0
            adjancency_matrix(i, field(i, k)) = 1;
        end
    end
end

end