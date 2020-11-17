function Plot_Stoc(varargin)

sizes = ["y", "z", "a", "f", "p", "n", "u", "m", "", "K", "M", "G", "T", "P", "E", "Z", "Y"];

global IVs Model_names Plot_Vars Vars unit T_unit PlotVars

m = 0;

% If the first input is not a cell, it must contain all the models we wish
% to plot, otherwise it must be a cell of models and variables
if ~iscell(varargin{1})
    Models(varargin{1}(1), 'N');
    
    % If there is a second variable which is numeric, it must be the
    % variables we wish to plot, otherwise plot all variables
    if length(varargin) >= 2 && (isnumeric(varargin{2}) || iscell(varargin{2}) || all(ismember(varargin{2}, Vars)))
        a = {};
        
        % Create a, a cell of every model with all variables
        for i = 1:length(varargin{1})
            % If the second input is a cell, we have groups of variables we
            % would like to plot the sum of. If not, convert the array to a
            % cell
            if iscell(varargin{2})
                a = [a, {{varargin{1}(i), varargin{2}}}];
                m = m + length(varargin{2});
                
            else
                a = [a, {{varargin{1}(i), num2cell(varargin{2})}}];
                m = m + length(varargin{2});
            end
        end
        h = 3;
        
    else
        % Let a be an array of the models we will plot
        m = max(m, length(Vars));
        a = varargin{1};
        h = 2;
    end
    
else
    % Convert any non cell variable inputs to cell inputs
    a = varargin{1};
    for i = 1:length(a)
        if ~iscell(a{i}{2})
            a{i}{2} = num2cell(a{i}{2});
            m = m + length(a{i}{2});
        else
            m = m + length(a{i}{2});
        end
    end
    h = 2;
end

T = 0;
Style = 0;
% Check for the options
while h <= length(varargin)
    % If there is an option "T", T to the next input
    if varargin{h} == "T"
        T = varargin{h + 1};
        
        if h + 2 <= length(varargin) && ismember(varargin{h + 2}, sizes)
            T_uns = varargin{h + 2};
            h = h + 3;
            
        else
            T_uns = "";
            h = h + 2;
        end
        
        % If there is an option "Proportion", let Style be set to 1
    elseif varargin{h} == "Proportion"
        Style = 1;
        h = h + 1;
        
        % If there is an option "Count", let Style be set to 2, and let the
        % next input be the variable we will be counting
    elseif varargin{h} == "Count"
        Count = vars2nums(varargin{h + 1});
        Style = 2;
        h = h + 2;
        
        % If there is an option "Concentration", do nothing as Style is already
        % set to 0
    elseif varargin{h} == "Concentration"
        h = h + 1;
    end
end

% If no time is stated, find the time to plot by finding when all variables
% of all models are close to its steady state.
if T == 0
    b = inf;
    
    if iscell(a)
        for i = 1:length(a)
            Models(a{i}{1}, 'N');
            
            [new_T, T_uns] = Time_to_SS(a{i}{1}, cell2mat(vars2nums(a{i}{2})));
            T = max(T, new_T);
            
            [~, new_b] = ismember(T_uns, sizes);
            b = min(b, new_b);
        end
    else
        for i = 1:length(a)
            Models(a(i), 'N');
            
            [new_T, T_uns] = Time_to_SS(a(i));
            T = max(T, new_T);
            
            [~, new_b] = ismember(T_uns, sizes);
            b = min(b, new_b);
        end
    end
    
    T_uns = sizes(b);
end

Legend = strings(100, 1);
h = 1;

plots = zeros(100, m + 1, length(a));
uns = strings(1, m, length(a));

figure();

hold on;

% For every model
for i = 1:length(a)
    
    % If we have stated variable inputs
    if iscell(a)
        % Run the model to get the correct parameters
        Models(a{i}{1}, 'N');
        
        groups = vars2nums(a{i}{2});
        
        % Create Groups which is the label for each group in groups
        Groups = string(length(groups));
        for j = 1:length(groups)
            %Groups(j) = Plot_Vars(groups{j}(1));
            Groups(j) = PlotVars(groups{j}(1));
            for k = 2:length(groups{j})
                %Groups(j) = strcat(Groups(j), " + ", Plot_Vars(groups{j}(k)));
                Groups(j) = strcat(Groups(j), " + ", PlotVars(groups{j}(k)));
            end
        end
        
        Model_name = Model_names(a{i}{1});
    else
        % Run the model
        Models(a(i), 'N');
        
        groups = num2cell(1:length(Plot_Vars));
        
        % Create Groups which is the label for each group in groups
        %Groups = string(Plot_Vars);
        Groups = string(PlotVars);
        
        Model_name = Model_names(a(i));
    end
    
    if true
    	datas = Stochastic(a{i}{1}, T, [groups{:}]);
        
        % num = ceil(length(plots)/2) + 2;
        % subplot(num, 2, 1:4);
        
        % plot(datas(:, 1, 1), datas(:, plots + 1, 1));
        % hold on;
        % plot(datas(:, 1, 2), datas(:, plots + 1, 2));
        % plot(datas(:, 1, 3), datas(:, plots + 1, 3));
        % plot(datas(:, 1, 4), datas(:, plots + 1, 4));
        % hold off;

        % for i = 1:length(plots)
        %     j = plots(i);
        %     subplot(num, 2, i + 4);
        %     vec = Time(end, j + 1, :);
        %     b = [transpose(unique(vec)); sum(vec(:) == transpose(unique(vec)), 1)];
        %     bar(b(1, :), b(2, :));
        % end
    else
    
    T_new = equiv(T, T_uns, T_unit);
    
        % Run the model using ode15s
        [t, y] = ode15s(@ODEs, [0, T_new], IVs);
        plots(1:length(t), 1, i) = equiv(t, T_unit, T_uns);


        % For each group we want to plot
        for j = 1:length(groups)
            % If we are plotting Proportion
            if Style == 1
                % Find out how many of each variable can be created
                div = min(Write_Final_Eqn("Max_Num", groups{j}), [], 1);

                % Divide each variable by the amount that can be created.
                y(:, groups{j}) = y(:, groups{j})./div;

            elseif Style == 2
                % Find out how many of variable Count is in each variable
                mult = how_many_in(Count, groups{j});

                % Multiply each variable by how many of count is in it
                y(:, groups{j}) = mult .* y(:, groups{j});
            end

            % Plot the group
            plots(1:length(t), j + 1, i) = sum(y(:, groups{j}), 2);

            % Add the model and group to the legend
            %         Legend(h) = strcat("Model ", Model_name, ", var ", Groups(j));
            Legend(h) = strcat(Groups(j));
            h = h + 1;
            
        end
    plots(length(t) + 1:end, :, i) = NaN;
    plots(:, length(groups) + 2:end, i) = NaN;
    
    uns(1, :, i) = unit;
    end
end

if Style == 0
    [~, b] = ismember(uns, sizes);
    
    v = max(max(plots(:, 2:end, :).* 10 .^ (3 * (b - 9))));
    
    m = min(v(:));
    
    Log = floor(log10(m)/3);
    
    units = sizes(9 + Log);
    
    plots(:, 2:end, :) = equiv(plots(:, 2:end, :), uns, units);
end

for i = 1:length(a)
    plot(plots(:, 1, i), plots(:, 2:end, i), 'LineWidth',5);
    set(gcf,'Position',[500 200 1000 700]);
    set(gca,  'FontSize', 30);
end

% Add the legend to the plot
if h == 2
    legend({Legend(1:h - 1)}, 'FontSize', 20);
else
    legend(Legend(1:h - 1), 'FontSize', 20);
end

% Add the legend and label the axis


xlabel(strcat("Time, ", T_uns, "s"), 'FontSize',30);
if Style == 0
    ylabel(strcat("Concentration, ", units, "M"), 'FontSize',30);
    
elseif Style == 1
    %     ylabel("Receptor Occupancy x100 (%age)");
    ylabel('Fraction of Species', 'FontSize',30);
    
elseif Style == 2
    ylabel(strcat("Counting variable ", Vars(Count), 'FontSize', 30));
end

%  title(strcat(Model_names(1)));

hold off;

end