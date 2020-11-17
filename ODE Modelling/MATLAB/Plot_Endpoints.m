function endpoints = Plot_Endpoints(Type, models, Var, Points, groups, varargin)

% Plot_Endpoints:
%
% This function will plot the sum of the endpoints of groups, in Model
% model, with the variation of the 'Type', where Type is either 'IV' or 'K'
%
% See also: Plot_Change
%
% Author: Sean Watson  Date: 06/08/2019  Version: v0.1

global Plot_Vars Model_names unit T_unit K_units units_final k_val K varz K_un;


var_unit = unit;





if ~iscell(groups)
    groups = num2cell(groups);
end

% Check whether we are changing the intial value of the k values, then run
% the code. This will output the endpoints of desired models
endpoints = Plot_Change(Type, models, Var, Points, groups, varargin{:});

% Let m be the number of groups
n = length(models);
m = length(groups);

% Plot the concentration endpoints against the changing variable
for i = 1:n
%      plot(endpoints(:, 1, i), endpoints(:, 2:m + 1, i), 'LineWidth',2);
     semilogx(endpoints(:, 1, i), sum(endpoints(:, 2:m + 1, i), 2), 'LineWidth',2);
    set(gcf,'Position',[500 200 1000 700]);

    % Allow more lines to be plotted
    hold on;

    % If there are more than 2 plot variables, also plot their sum
    if m >= 4
%          plot(endpoints(:, 1, i), sum(endpoints(:, 2:m + 1, i), 2), 'LineWidth',2);
         semilogx(endpoints(:, 1, i), sum(endpoints(:, 2:m + 1, i), 2), 'LineWidth',2);
         disp(i/n);
        set(gcf,'Position',[500 200 1000 700]);
    end
end

% Label the axis depending on the variable we were changing
if Type == "IV"
    xlabel(strcat("log[" , Plot_Vars(Var), "]"), 'FontSize',20);
    
elseif Type == "KD"
    
    if size(K, 1) == 1 && varz > 1
        disp("1111111111111");
        xlabel(strcat("k_{d} ", unit, "M"), 'FontSize',20);
    elseif size(K, 1) == 1 
        disp("2222222222222");
        xlabel(strcat("k_{d} (", unit, "M) while varying backward rate constant"), 'FontSize',20);
    elseif size(K, 1) > 1 && varz > 1
        disp("3333333333333");
        xlabel(strcat("k_{d}_(_{", num2str(varz), "}_) (", unit, "M)"), 'FontSize',20);
    elseif size(K, 1) > 1
        disp("44444444444444");
        xlabel(strcat("k_{d}_(_{", num2str(varz), "}_) (", unit, "M)"), 'FontSize',20);
    else
        xlabel(strcat("k_{d}_(_{", num2str(varz), "}_) (", unit, "M)"), 'FontSize',20);
    end
elseif Type == "K"
    xlabel(strcat("k", num2str(Var)), 'FontSize',20);

else
    xlabel("Viola!");
end

% Label the y axis


%ylabel(strcat("Final concentration ", units_final, "M"));
%ylabel('\theta_b', 'FontSize',20);
ylabel("Fraction of [LR^2]", 'FontSize',20);

% Let Groups be the names of the variables in each group
Groups = strings(m, 1);
for i = 1:m
    Groups(i) = Plot_Vars(groups{i}(1));
    for j = 2:length(groups{i})
        Groups(i) = strcat(Groups(i), " + ", Plot_Vars(groups{i}(j)));
    end
end
        
% Add the variable names to the legend, and "All" for the sum of them all.
if m >= 2
    legend([Groups; "All"]);
else
    legend(Groups);
end

title(Model_names(models));

% Don't allow the graph to be added to
hold off;

end