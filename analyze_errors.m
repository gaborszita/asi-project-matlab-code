errorfile = 'errors/path_1_long_23_10_31_06_27_14.csv';
close all;

drifts = readmatrix(errorfile);
%interval = 20;
%plot_drifts(drifts, interval, 'm');
%interval = 40;
%plot_drifts(drifts, interval, 'r');
%interval = 60;
%plot_drifts(drifts, interval, 'y');
%interval = 75;
%plot_drifts(drifts, interval, 'g');
%interval = 100;
%plot_drifts(drifts, interval, 'c');
%interval = 120;
%plot_drifts(drifts, interval, 'm');
%interval = 145;
%plot_drifts(drifts, interval, 'r');
interval = 170;
plot_drifts(drifts, interval, 'b');

function plot_drifts(drifts, interval, colorArg)

colorArray = ['r', 'g', 'b', 'c', 'm', 'y', 'k'];
colorArray = repmat(colorArray, 1, 10);

for i = 1:interval*floor(length(drifts)/interval)
    if nargin <= 2
        color = colorArray(floor(i/interval)+1);
    else
        color = colorArg;
    end
    hold on;
    plot(drifts(1, i), drifts(2, i), 'o', 'Color', color);
    if mod(i, interval) == 1
        %disp(interval*floor(i/interval)+1:interval*floor(i/interval)+interval);
        [xmid, xlow, xhigh, ymid, ylow, yhigh] = calculate_bounds(drifts(:, interval*floor(i/interval)+1:interval*floor(i/interval)+interval));
        plotcircle(xmid, xlow, xhigh, ymid, ylow, yhigh, color);
    end
    hold off;
end

end

function [xmid, xlow, xhigh, ymid, ylow, yhigh] = calculate_bounds(data)

bound_percentile = 95;

xmid = median(data(1, :));
ymid = median(data(2, :));

xlow = prctile(data(1, :), 100-bound_percentile);
xhigh = prctile(data(1, :), bound_percentile);

ylow = prctile(data(2, :), 100-bound_percentile);
yhigh = prctile(data(2, :), bound_percentile);

end

function plotcircle(xmid, xlow, xhigh, ymid, ylow, yhigh, color)

% Calculate the semi-major and semi-minor axes lengths
a = (xhigh - xlow) / 2;
b = (yhigh - ylow) / 2;

% Calculate the center of the ellipse
x_center = xmid;
y_center = ymid;

% Plot the ellipse
rectangle('Position', [x_center - a, y_center - b, 2 * a, 2 * b], ...
    'Curvature', [1, 1], 'EdgeColor', color);

end