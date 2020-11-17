h = 104;
j = 1;
j1 = h + 1;
links = zeros(100, 2);

for i = 1:1000
    if LR(i, end) ~= 0
        links(j:j + LR(i, end) - 1, :) = [transpose(j:j + LR(i, end) - 1), j1 * ones(LR(i, end), 1)];
        j1 = j1 + 1;
        j = j + LR(i, end);
    end
end

links = links(1:j - 1, :);

p = plot(graph(links(:, 1), links(:, 2)), 'Layout', 'force');
text(p.XData(1:h), p.YData(1:h), 'R', 'FontSize', 8, 'FontWeight', 'bold');
text(p.XData(h + 1:j1 - 1), p.YData(h + 1:j1 - 1), 'L', 'FontSize', 8, 'FontWeight', 'bold');