startEndTimes = get_start_end_times();
drifts = zeros(2, length(startEndTimes));

parfor i = 1:length(startEndTimes)-1
    
    time1 = startEndTimes{i, 1};
    time2 = startEndTimes{i, 2};
    
    %[mouse_gyro_times, xTransformMG, yTransformMG, angleTransformMG, ...
    %    xOverTimeMG, yOverTimeMG, angleOverTimeMG] = get_mouse_gyro_pos(time1, time2);
    
    [lidar_times, xTransform, yTransform, angleTransform, ...
        xOverTime, yOverTime, angleOverTime, rmseOvertime] = lidar_icp_4(time1, time2);
 
    drifts(:, i) = [xTransform, yTransform];
    
    disp(['Progress: ' num2str(i) '/' num2str(length(startEndTimes))]);
end

figure(1);

for i = 1:length(drifts)
    hold on;
    plot(drifts(1, i), drifts(2, i), 'o');
    hold off;
end

figureCnt = 2;
figure(figureCnt);

for i = 1:length(drifts)
    if mod(i, 50) == 0 
        figureCnt = figureCnt + 1;
        figure(figureCnt);
    end
    hold on;
    plot(drifts(1, i), drifts(2, i), 'o');
    hold off;
end