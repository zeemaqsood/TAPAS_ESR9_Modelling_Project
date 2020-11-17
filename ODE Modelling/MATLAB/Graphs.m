function Graphs

sizes = ["y", "z", "a", "f", "p", "n", "u", "m", "", "K", "M", "G", "T", "P", "E", "Z", "Y"];

global Plot_Vars Vars constants n IVs K K_unit K_units unit T_unit;

% Creates a list of all edges, thick_edges and dotted edges
[edges, thick_edges, dotted_edges] = create_links;

m = max(max(edges));

% Create a list of all colours
colours = ['r', 'b', 'g', 'c', 'm', 'y', 'k', 'w'];

% Produce a directional graph using the edges produced in create_links
G = digraph(edges(:, 1), edges(:, 2), edges(:, 3));

% Produce the edge labels which is a k followed by the weight of the
% edge
EdgeLabels = cell(size(G.Edges.Weight, 1), 1);

if isempty(thick_edges)
    for i = 1:size(G.Edges.Weight, 1)
        EdgeLabels{i} = strcat('k', num2str(G.Edges.Weight(i)));
    end
else
    Extra_weight = thick_edges(:, 3);
    
    for i = 1:size(G.Edges.Weight, 1)
        mult = unique(Extra_weight(all(thick_edges(:, 1:2) == G.Edges.EndNodes(i, :), 2)));
        
        if ~isempty(mult)
            EdgeLabels{i} = strcat(num2str(mult(1)), 'k', num2str(G.Edges.Weight(i)));
        else
            EdgeLabels{i} = strcat('k', num2str(G.Edges.Weight(i)));
        end
    end
end

figure();

% Plot the graph using the edge labels
p = plot(G,'EdgeLabel', EdgeLabels, 'LineWidth', 3, 'ArrowSize', 16, 'Layout', 'layered', 'NodeLabel', {});

% Create a list of the formal variable names, followed by blanks
vars = [Plot_Vars; cell(m - n, 1)];
for i = n + 1:m
    vars{i} = '';
    disp(vars{i});
end

% Add the formal variable names as text to the nodes so I can adjust the
% type size
text(p.XData, p.YData, vars, 'FontSize', 20, 'FontWeight', 'Bold');

% Remove any dummy nodes, nodes which are not variables
highlight(p, n + 1:m, 'Marker', 'none');

% Colour the nodes depenndant on the kind of reaction, i.e. what their k
% value is
for i = 1:size(G.Edges.EndNodes, 1)
	a = G.Edges.EndNodes(i, :);
    highlight(p, a, 'MarkerSize', 10, 'EdgeColor', colours(abs(floor(G.Edges.Weight(i)))));
end

% Create any multiple likely edges thicker
if ~isempty(thick_edges)
    highlight(p, thick_edges(:, 1), thick_edges(:, 2), 'LineWidth', 6);
end

% Create a dotted edge for all edges in dotted edge.
if ~isempty(dotted_edges)
    % Create a var of edges
    dum = G.Edges.EndNodes(:, 1:2);
    
    for i = 1:size(dotted_edges, 1) 
        % Find the first occurence of the dotted edge and make it dotted
        k = find(all(ismember(dum, dotted_edges(i, :)), 2), 1);
        highlight(p, 'Edges', k, 'LineStyle', '--');
        
        % Set the occurence of that dotted edge to zeros so we cant find it
        % again
        dum(k, :) = [0, 0];    
    end
end

% Create all constant variable nodes to red
if ~isempty(constants)  
    highlight(p, constants, 'NodeColor', 'r');
end

% Display all the initial values in a table
IV = table(Vars, strcat(num2str(IVs), " ", unit, "M"));
IV.Properties.VariableNames{2} = 'IVs';
disp(IV);

% Display all the k values in a table
k_num = strcat("k", num2str(transpose(1:size(K, 1))));

[~, b] = ismember(T_unit, sizes);
Ks = K .* 10 .^ (3 .* (9 - b));

Kays = strcat(string(Ks), " ", K_unit, "M^{", string(K_units), "}s^{-1}");
Kays(K_units == 0) = strcat(string(Ks(K_units == 0)), " ", T_unit, "s^{-1}");
Forw = Kays(:, 1);
Rev = Kays(:, 2);
T = table(k_num, Forw, Rev);
disp(T);

% Display the ODE's in a table
Eqns = Write_Eqns;
Eqns = table(Eqns);
disp(Eqns);

end