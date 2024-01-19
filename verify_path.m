function pathcorrect = verify_path(path)

field = get_field();

intersection = 1;

for i=1:length(path)
    if strcmp(path{i}, 'Straight')
        intersection = field(intersection, 1);
    elseif strcmp(path{i}, 'Left')
        intersection = field(intersection, 2);
    elseif strcmp(path{i}, 'Right')
        intersection = field(intersection, 3);
    end
    if intersection == 0
        break
    end
end

pathcorrect = intersection == 1;

end