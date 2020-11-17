function Within_SS(model, vars, varargin)

global Vars IVs

SS = Steady_States(model);

Time = Plot(model, vars, "Stochastic2", varargin{:});
fig = gcf;

hold on;

colours = ['r', 'b', 'g', 'c', 'm', 'y', 'k', 'w'];
v = zeros(length(vars), 3);
vec = zeros(size(Time, 1), 2, length(vars));
vec(:, 1, :) = Time(:, 1, 1) .* ones(size(Time, 1), 1, length(vars));

for i = 1:length(vars)
    v(i, 1) = eval(strcat("SS.", Vars(vars(i))));
    v(i, 2) = v(i, 1) + 0.05 * abs(v(i, 1) - IVs(vars(i)));
    v(i, 3) = v(i, 1) - 0.05 * abs(v(i, 1) - IVs(vars(i)));
    plot(xlim(), [v(i, 1), v(i, 1)], colours(i));
    plot(xlim(), [v(i, 2), v(i, 2)], colours(i), 'LineStyle', '-.');
    plot(xlim(), [v(i, 3), v(i, 3)], colours(i), 'LineStyle', '-.');
    
    vec(:, 2, i) = sum((Time(:, vars(i) + 1, :) >= v(i, 3)) .* (Time(:, vars(i) + 1, :) <= v(i, 2)), 3);
end

hold off;

for i = 1:length(vars)
    figure();
    bar(vec(:, 1, 1), vec(:, 2, 1));
end

end