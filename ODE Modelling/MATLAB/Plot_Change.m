function endpoints = Plot_Change(Type, models, var, Points, groups, varargin)

% Plot_Change:
%
% This function will change the var specified within the models specified
% and plot the groups specified. There are extra options available
% 
% inputs: Type: one of : "IV", "K", "KD"
%         models: [1, 2]
%         var: 1
%         Points: [1,2,3]; [1,10,100]; 10:10:100
%         groups: [1,2,3]; {[1,2], [3,4]} What we plot
%         Variable inputs can be either number or the variables you would
%         like to plot
%
% options: 'T', will plot from 0 to specified time
%          'Proportion', will plot as a proportion of possible number of
%                        each variable could be produced
%          'Concentration', this is the default, where it will just plot
%                           the concentration
%          'Count', will plot the variables multiplied by how many of the
%                   specified variable are in the variable
%
% See also: ODEs, Models, ode15s, Time_to_SS, how_many_in, vars2nums
%
% Author: Sean Watson  Date: 06/08/2019  Version: v0.1

sizes = ["y", "z", "a", "f", "p", "n", "u", "m", "", "K", "M", "G", "T", "P", "E", "Z", "Y"];

global IVs K Plot_Vars Model_names unit T_unit K_units units_final k_val varz K_un K_unit PlotVars;

h = 1;
Style = 0;
KDConst = 0;
T = 0;
var_unit = unit;

var = vars2nums(var);
varz = var;
var_sign = var;
groups = vars2nums(groups);




% Check the options
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
        
    elseif ismember(varargin{h}, sizes)
        var_unit = varargin{h};
        h = h + 1;
        
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
        
    % If there is an option KDConst, set var KDConst to 1
    elseif varargin{h} == "KDConst"
        KDConst = 1;
        h = h + 1;
    end
end

% If the time is not specified, find the time to show all plots
if T == 0
    if KDConst == 0
        [T, T_uns] = Time_to_SS(models, "Change", Type, var, Points);
    else
        
        [T, T_uns] = Time_to_SS(models, "Change", Type, var, Points, "KDConst");
    end
    
[~, b] = ismember(T_uns, sizes);
T_uns = sizes(b);
end

var = vars2nums(var);
groups = vars2nums(groups);

% Check for if the Type is K or KD, and assign whether it is for the
% forward or backwards reaction
if ismember(Type, ["K", "KD"])
    if var > 0
        b1 = 1;
    else
        
        var = - var;
        b1 = -1;
    end
end

if ~iscell(groups)
    groups = num2cell(groups);
end

% Let m denote the number of groups we will plot, and let n denote the
% number of values we will change the initial value to
m = length(groups);
n = length(Points);



% Let Groups be the names of the variables in each group
Groups = strings(m, 1);
for i = 1:m
    Groups(i) = Plot_Vars(groups{i}(1));
        simplegroupname = Groups(i); 
        simplegroupname2 = strsplit(simplegroupname, {'^', '{', '}'});
        simplegroupname3 = {1, length(simplegroupname2)};
        for z = 1:length(simplegroupname2)
            if isstrprop(simplegroupname2(z),'alpha')
            simplegroupname3{1, z} = simplegroupname2(z);
%             simplegroupname4 = strcat(simplegroupname4, simplegroupname3{1, z});
            elseif isstrprop(simplegroupname2(z),'digit')
                simplegroupname3{1, z} = simplegroupname2(z-1);
            else
                
            end
           
        end
        
        disp("Daddy");
        

    for j = 2:length(groups{i})
        Groups(i) = strcat(Groups(i), " + ", Plot_Vars(groups{i}(j)));
        
        
    end
%     disp(Groups);
    
    
end

% Set the legend have a space for all plot variables for all steps
Legend = strings(n * m * length(models), 1);

% Allow endpoints to be of the size, the number of plot variables by the
% number of steps
endpoints = zeros(n, m + 1, length(Points), length(models));

figure();

hold on;

plots = zeros(100, length(groups), length(Points), length(models));
uns = strings(1, length(groups), length(Points), length(models));


% k_val = num2str(b1 * var);

for k = 1:length(models)
    Models(models(k), 'N');
    
    KD = K(:, 2)./K(:, 1);
    
    if exist('var_unit', 'var')
        if Type == "IV"
            Points_new = equiv(Points, var_unit, unit);
            
        elseif Type == "K"
            Points_new = equiv(Points, var_unit, unit, K_units(var, 0.5 * (3 - b1)));

        elseif Type == "KD"
            K_un = K_units(var, 2) - K_units(var, 1);            
            Points_new = equiv(Points, var_unit, unit, K_un);
        end 
    end
    
    for i = 1:n
        % Find the value for the next step
        v = Points_new(i);
        
        % Set the initial value to the value of this step
        if Type == "IV"            
            IVs(var) = v;
            
        elseif Type == "K"
            K(var, 0.5 * (3 - b1)) = v;
            
            % If KDConst equals one, change the other reaction to allow KD
            % to stay the same
            if KDConst == 1
                if b1 == 1
                    K(var, 2) = KD(var) * K(var, 1);
                    
                else
                    K(var, 1) = K(var, 2)/KD(var);
                end
            end
            
        elseif Type == "KD"
            KD(var) = Points(i);
            
            if b1 > 0
                K(var, 1) = K(var, 2)/KD(var);
                
            else
                K(var, 2) = KD(var) * K(var, 1);
            end
        end
        
        T_new = equiv(T, T_uns, T_unit);
        
        % Simulate the model using ode15s
        [t, y] = ode15s(@ODEs, [0, T_new], IVs);
        plots(1:length(t), 1, i, k) = equiv(t, T_unit, T_uns);
        
        % Set the first column of endpoints to be the changing variable
        endpoints(i, 1, k) = v;
        
        % If a style was specified, change the values to satisfy this
        for j = 1:length(groups)
           if Style == 1
                div = min(Write_Final_Eqn("Max_Num", groups{j}), [], 1);

                for k1 = 1:length(groups{j})
                    y(:, groups{j}(k1)) = y(:, groups{j}(k1))/div(k1);
                end 
           elseif Style == 2
                mult = how_many_in(Count, groups{j});

                y(:, groups{j}) = mult .* y(:, groups{j});
           end
           
           plots(1:length(t), j + 1, i, k) = sum(y(:, groups{j}), 2);
            
           % Set the endpoints of the lines to the sum of the array endpoints
           endpoints(i, j + 1, k) = sum(y(end, groups{j}));
        end
        
        % Set the legend name to the group number plus the changing variable
        % name and its value
   
        
        if Type == "IV"
%             Legend((k - 1) * m * n + (i - 1) * m + 1:(k - 1) * m * n + i * m) = strcat(Model_names(models(k)), ", \theta_b at [", Plot_Vars(var), "] = ", num2str(v), " ", unit, "M");
                if unit == ""
                    Legend((k - 1) * m * n + (i - 1) * m + 1:(k - 1) * m * n + i * m) = strcat(Groups, " at ", Plot_Vars(var), " = ", num2str(v));
                else
                    Legend((k - 1) * m * n + (i - 1) * m + 1:(k - 1) * m * n + i * m) = strcat(Model_names(models(k)), ", [", Groups, "] at [", Plot_Vars(var), "] = ", num2str(v), " ", unit, "M");
                end
         elseif Type == "KD" && K_un == 1 
             if size(K, 1) > 1 && var_sign < 0
                  disp("Red");
                 K_un = K_units(var, 2) - K_units(var, 1);
                   Legend((k - 1) * m * n + (i - 1) * m + 1:(k - 1) * m * n + i * m) = strcat(Model_names(models(k)), ", [", Groups, "] at k_-_", num2str(var), " = ", num2str(v), " ", unit, "M");
%                   Legend((k - 1) * m * n + (i - 1) * m + 1:(k - 1) * m * n + i * m) = strcat("[LLRR] at k_-_", num2str(var), " = ", num2str(v), " ", K_unit, "M");
%                 Legend((k - 1) * m * n + (i - 1) * m + 1:(k - 1) * m * n + i * m) = strcat(Model_names(models(k)), ", \theta_b at k_d_(_-_",num2str(var), "_)", num2str(v), " ", unit, "M");
             
             elseif size(K, 1) > 1 && var_sign > 0
                  
                 K_un = K_units(var, 2) - K_units(var, 1);
                 Legend((k - 1) * m * n + (i - 1) * m + 1:(k - 1) * m * n + i * m) = strcat("[LLRR] at k_", num2str(var), " = ", num2str(v), " ", K_unit, "M"); 
%                  Legend((k - 1) * m * n + (i - 1) * m + 1:(k - 1) * m * n + i * m) = strcat(Model_names(models(k)), ", \theta_b at k_d_(_",num2str(var), "_)", num2str(v), " ", unit, "M");
             else
                 
                K_un = K_units(var, 2) - K_units(var, 1);
                Legend((k - 1) * m * n + (i - 1) * m + 1:(k - 1) * m * n + i * m) = strcat(Model_names(models(k)), ", \theta_b at k_d ", num2str(v), " ", unit, "M");
             end
        elseif Type == "KD" && K_un > 1
            if length(K) > 1 && var_sign < 0
                 disp("Red > 1 ");
                K_un = K_units(var, 2) - K_units(var, 1);
%                 Legend((k - 1) * m * n + (i - 1) * m + 1:(k - 1) * m * n + i * m) = strcat(Model_names(models(k)), ", \theta_b at k_d_(_-_", num2str(var), "_) = ", num2str(v), " ", unit, "M^{", num2str(K_un), "}");
                Legend((k - 1) * m * n + (i - 1) * m + 1:(k - 1) * m * n + i * m) = strcat(Model_names(models(k)), ", [", Groups, "] at k_d_(_-_", num2str(var), "_) = ", num2str(v), " ", unit, "M^{", num2str(K_un), "}");                
            
            elseif length(K) > 1 && var_sign > 0                 disp("Yellow > 1");
                K_un = K_units(var, 2) - K_units(var, 1);
%                 Legend((k - 1) * m * n + (i - 1) * m + 1:(k - 1) * m * n + i * m) = strcat(Model_names(models(k)), ", \theta_b at k_d_(_", num2str(var), "_) = ", num2str(v), " ", unit, "M^{", num2str(K_un), "}");
                Legend((k - 1) * m * n + (i - 1) * m + 1:(k - 1) * m * n + i * m) = strcat("[", Groups, "] at k_d_(_", num2str(var), "_) = ", num2str(v), " ", unit, "M^{", num2str(K_un), "}");
            else
                 disp("Blue > 1");
                K_un = K_units(var, 2) - K_units(var, 1);
                Legend((k - 1) * m * n + (i - 1) * m + 1:(k - 1) * m * n + i * m) = strcat(Model_names(models(k)), ", \theta_b at k_d = ", num2str(v), " ", unit, "M^{", num2str(K_un), "}");
            end
        else
            disp("blah blah");
            if K_units(var, 0.5 * (3 - b1)) == 0
%                 Legend((k - 1) * m * n + (i - 1) * m + 1:(k - 1) * m * n + i * m) = strcat(Model_names(models(k)), ", [", Groups, "] at k_{", num2str(b1 * var), "} = ", num2str(v), " ", T_unit, "s^{-1}");
                  Legend((k - 1) * m * n + (i - 1) * m + 1:(k - 1) * m * n + i * m) = strcat(Model_names(models(k)), ", \theta_b at k_{", num2str(b1 * var), "} = ", num2str(v), " ", T_unit, "s^{-1}");
            else
                Legend((k - 1) * m * n + (i - 1) * m + 1:(k - 1) * m * n + i * m) = strcat(Model_names(models(k)), ", \theta_b at k_{", num2str(b1 * var), "} = ", num2str(v), " ", unit, "M^{", num2str(K_units(var, 0.5 * (3 - b1))), "}", T_unit, "s^{-1}");
            end
        end
        
        plots(length(t) + 1:end, :, i, k) = NaN;
    end
        
    uns(1, :, :, k) = unit;
end

if Style == 0
    [~, b] = ismember(uns, sizes);

    v = max(max(plots(:, 2:end, :).* 10 .^ (3 * (b - 9))));
    
    m = min(v(v ~= 0));

    Log = floor(log10(m)/3);
    
    if isempty(Log)
        [~, b] = ismember(unit, sizes);
        Log = b - 9;
    end
    
    units = sizes(9 + Log);
    
    plots(:, 2:end, :, :) = equiv(plots(:, 2:end, :, :), uns, units);
    
end

for k = 1:length(models)
    
    for i = 1:n
        m = sum(plots(:, 1, i, k) ~= 0) + 1;
            plot(plots(1:m, 1, i, k), plots(1:m, 2:end, i, k), 'LineWidth',5);
            set(gcf,'Position',[500 200 1000 700]);
             set(gca,  'FontSize', 20);
            
    end
end

% Add the legend and label the axis
legend(Legend);
xlabel(strcat("Time, ", T_unit, "s"), 'FontSize',30);


if Style == 0
    if unit == ""
        ylabel(strcat("Number of Species"), 'FontSize',30);
    else
    units_final = units;
    ylabel(strcat("Concentration ", units_final, "M"), 'FontSize',30);
    end
elseif Style == 1
%       ylabel(strcat("Fraction of [", Groups, "]"), 'FontSize',20);
%         ylabel('\theta_b', 'FontSize', 14);
        ylabel(strcat("Fraction of species"), 'FontSize',30);
else
    ylabel('\theta_b', 'FontSize',20);
  
end
title(Model_names(models));

% Allow no more lines to be added to the plot
hold off;

% Reset the initial value
end