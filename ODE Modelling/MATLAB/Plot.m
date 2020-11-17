function varargout = Plot(varargin)

% Plot:
%
% This function will plot the models with any specified groups. If no
% groups specified, it will plot all variables. There are also extra
% options.
%
% inputs: [1, 2]; [1, 2], [2, 4]; {{1, [1, 2]}, {2, [3, 4]}}
%          Variable inputs can be either number or the variables you would
%          like to plot
%
% options: 'T', will plot from 0 to specified time
%          'Proportion', will plot as a proportion of possible number of
%                        each variable could be produced
%          'Concentration', this is the default, where it will just plot
%                           the concentration
%          'Count', will plot the variables multiplied by how many of the
%                   specified variable are in the variable
%
% See also: Models, ODEs, ode15s, Time_to_SS, how_many_in, vars2nums
%
% Author: Sean Watson  Date: 06/08/2019  Version: v0.1

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
stochastic = 0;
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
        
    elseif varargin{h} == "Stochastic"
        h = h + 1;
        stochastic = 1;
        
    elseif varargin{h} == "Stochastic2"
        h = h + 1;
        stochastic = 2;
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

% hold on;

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
%             Groups(j) = Plot_Vars(groups{j}(1));
            Groups(j) = PlotVars(groups{j}(1));
            for k = 2:length(groups{j})
                %Groups(j) = strcat(Groups(j), " + ", Plot_Vars(groups{j}(k)));
                Groups(j) = strcat(Groups(j), " + ", Plot_Vars(groups{j}(k)));
            end
        end
        
        Model_name = Model_names(a{i}{1});
    else
        % Run the model
        Models(a(i), 'N');
        
        groups = num2cell(1:length(Plot_Vars));
        
        % Create Groups which is the label for each group in groups
        %Groups = string(Plot_Vars);
        Groups = string(Plot_Vars);
        
        Model_name = Model_names(a(i));
    end
    
    T_new = equiv(T, T_uns, T_unit);
    
    if stochastic > 0
        if iscell(a)
            [~, new_b] = ismember(T_uns, sizes);
            
            if stochastic == 1
                Time = Stochastic(a{i}{1}, T * 10^(3 * (new_b - 9)));
            else
                Time = stoc_test1(a{i}{1}, T * 10^(3 * (new_b - 9)));
            end
            varargout{1} = Time;
        else 
            [~, new_b] = ismember(T_uns, sizes);
            
            if stochastic == 1
                Time = Stochastic(a(i), T * 10^(3 * (new_b - 9)));
            else
                Time = stoc_test1(a(i), T * 10^(3 * (new_b - 9)));
            end
            
            varargout{1} = Time;
        end
            
        if Style == 1
            div = min(Write_Final_Eqn("Max_Num", 1:length(Vars)), [], 1);
            
            Time(:, (1:length(Vars)) + 1, :) = Time(:, (1:length(Vars)) + 1, :)./div;
        end
        
        t = equiv(Time(:, 1, 1), T_unit, T_uns);
        
        y = zeros([size(Time, 1), size(Time, 2) - 1, 4]);
        y(:, :, 1) = mean(Time(:, 2:end, :), 3);
        y(:, :, 2) = prctile(Time(:, 2:end, :), 5, 3);
        y(:, :, 3) = prctile(Time(:, 2:end, :), 50, 3);
        y(:, :, 4) = prctile(Time(:, 2:end, :), 95, 3);
        
        plots = zeros(size(t, 1), size(groups, 2) + 1, 4);
        plots(:, 1, :) = t .* ones(length(t), 1, 4);
        
        for j = 1:length(groups)
            for i1 = 1:4
                plots(1:length(t), j + 1, i1) = sum(y(:, groups{j}, i1), 2);
            end
        end
    else
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
    end
    
    plots(length(t) + 1:end, :, i) = NaN;
    plots(:, length(groups) + 2:end, i) = NaN;
    
    uns(1, :, i) = unit;
end

if stochastic > 0
    num = ceil(length(groups)/2) + 2;
%     subplot(num, 2, 1:4);
    hold on;
    
    colours = ['r', 'b', 'g', 'c', 'm', 'y', 'k', 'w'];
    
    if Style == 0
        [~, b] = ismember(uns, sizes);
        
        v = max(max(plots(:, 2:end, :).* 10 .^ (3 * (b - 9))));
        
        m = min(v(:));
        
        Log = floor(log10(m)/3);
        
        units = sizes(9 + Log);
    end
    
    h = zeros(length(groups) + 3, 1);
    
    for i = 1:length(groups)
        plot(plots(:, 1, 1), plots(:, i + 1, 1), colours(i), 'LineWidth',5);
        plot(plots(:, 1, 2), plots(:, i + 1, 2), colours(i), 'LineStyle', ':', 'LineWidth',3);
        plot(plots(:, 1, 3), plots(:, i + 1, 3), colours(i), 'LineStyle', '--', 'LineWidth',5);
        plot(plots(:, 1, 4), plots(:, i + 1, 4), colours(i), 'LineStyle', ':', 'LineWidth',3);
        
        h(i) = plot(NaN, NaN, colours(i));
         Legend(i) = strcat(Groups(i));
    end
    
     h(length(groups) + 1) = plot(NaN, NaN, 'k');
     h(length(groups) + 2) = plot(NaN, NaN, 'k', 'LineStyle', '--');
     h(length(groups) + 3) = plot(NaN, NaN, 'k', 'LineStyle', ':');
%      Legend(length(groups) + 1:length(groups) + 3) = ["Mean", "Median", "p5 & p95"];
%      legend(h, Legend(1:length(groups) + 3));
      lgd = legend(h, Legend(1:length(groups)));
%      [h,icons,plots,str] = legend(h, Legend(1:length(groups)), 'Location','NorthEast');
     
     
%      set(icons(:),'LineWidth',5);
     set(gcf, 'Position',[500 200 750 500]);
     set(gca, 'FontSize', 30, 'LineWidth', 3);
     set(findall(gca,'Type','Line'),'LineWidth',4)
      
    
    
    xlabel(strcat("Time, ", T_uns, "s"), 'FontSize',30);
    if Style == 0
%         ylabel(strcat("Concentration, ", units, "M"), 'FontSize', 15);
        ylabel(strcat("Number of Receptors"), 'FontSize', 30);
        
    elseif Style == 1
        %     ylabel("Receptor Occupancy x100 (%age)");
        ylabel('Fraction of Species', 'FontSize',30);
    end
    
%     vec = Time(end, :, :);
%     for i1 = 1:length(groups)
%         subplot(num, 2, i1 + 4);
%         vecr = sum(vec(:, groups{i1} + 1, :), 2);
%         b = [transpose(unique(vecr)); sum(vecr(:) == transpose(unique(vecr)), 1)/100];
%         bar(b(1, :), b(2, :));
%         title(strcat("Distribution of final amount of ", Groups(i1)));
%         xlabel('Final amount');
%         ylabel('%');
%     end
     
else
    if Style == 0
        [~, b] = ismember(uns, sizes);
        
        v = max(max(plots(:, 2:end, :).* 10 .^ (3 * (b - 9))));
        
        m = min(v(:));
        
        Log = floor(log10(m)/3);
        
        units = sizes(9 + Log);
        
        plots(:, 2:end, :) = equiv(plots(:, 2:end, :), uns, units);
    end
    
   colours = ['r', 'b', 'g', 'c', 'm', 'y', 'k', 'w'];
    
    for i = 1:length(a)
        
       
        
        
        % plot(plots(:, 1, i), plots(:, 2:end, i).* 10 .^ (3 .* (find(units == sizes, 1) - 9)), 'LineWidth',5);
        %plot(plots(:, 1, i), plots(:, 2:end, i).* 10 .^ (3 .* (find(unit == sizes, 1) - 9)), colours(i), 'LineWidth',5);
        %plot(plots(:, 2:end, i).* 10 .^ (3 .* (find(units == sizes, 1) - 9)), colours(1), 'LineWidth',5);
        hold on;
       
        plot(plots(:, 1, i),colours(2), 'LineWidth',5);
        
        
        
        disp(i)
        
        %hold on;
       
        set(gcf, 'Position',[500 200 1000 700]);
        set(gca, 'FontSize', 30, 'LineWidth', 3);
        
        
       

 
    hold off;
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
         if unit == ""
        ylabel(strcat("Number of Species"), 'FontSize',30);
    else
    
    ylabel(strcat("Concentration ", units, "M"), 'FontSize',30);
    end
       
        
    elseif Style == 1
        %     ylabel("Receptor Occupancy x100 (%age)");
        ylabel('Fraction of Species', 'FontSize', 30);
        
        
    elseif Style == 2
        ylabel(strcat("Counting variable ", Vars(Count), 'FontSize', 30));
    end
end

%  title(strcat(Model_names(1)));

hold off;
end
