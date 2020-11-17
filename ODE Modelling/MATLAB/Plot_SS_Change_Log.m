function SS = Plot_SS_Change_Log(Type, models, var, Points, groups, varargin)

sizes = ["y", "z", "a", "f", "p", "n", "u", "m", "", "K", "M", "G", "T", "P", "E", "Z", "Y"];

global IVs K Vars Plot_Vars Model_names unit K_units T_unit PlotVars

h = 1;
Style = 0;
KDConst = 0;
varz = var;
var = vars2nums(var);
groups = vars2nums(groups);

var_unit = unit;
disp(var_unit);

% Check the options
while h <= length(varargin)
    % If there is an option "Proportion", let Style be set to 1
    if ismember(varargin{h}, sizes)
        var_unit = varargin{h};
            
        h = h + 1;        
    
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
    for j = 2:length(groups{i})
        Groups(i) = strcat(Groups(i), " + ", Plot_Vars(groups{i}(j)));
    end
end

% Set the legend have a space for all plot variables for all steps
Legend = strings(m * length(models), 1);

% figure();

% hold on;

SS = zeros(length(Points), length(groups) + 1, length(models));
uns = strings(1, length(groups), length(models));

for k = 1:length(models)
    Models(models(k), 'N');
    
    KD = K(:, 2)./K(:, 1);
    
    if exist('var_unit', 'var')
        if Type == "IV"
            Points_new = equiv(Points, var_unit, unit);
            
        elseif Type == "K"
            Points_new = equiv(Points, var_unit, unit, K_units);
            var_unit = varargin{h};

        elseif Type == "KD"
            K_un = K_units(:, 2) - K_units(:, 1);            
            Points_new = equiv(Points, var_unit, unit, K_un);
        end 
    else
        Points_new = Points;
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
        
        % Set the first column of endpoints to be the changing variable
        SS(i, 1, k) = v;
        
        S = Steady_States(false, models(k));
        
        % If a style was specified, change the values to satisfy this
        for j = 1:length(groups)
            sums = 0;
                        
            if Style == 1
                div = min(Write_Final_Eqn("Max_Num", groups{j}), [], 1);

                for k1 = 1:length(groups{j})
                    eval(['sums = sums + S.', Vars{groups{j}(k1)}, '/div(k1);']);
                end
                
            elseif Style == 2
                mult = how_many_in(Count, groups{j});
                
                for k1 = 1:length(groups{j})
                    eval(['sums = sums + S.', Vars{groups{j}(k1)}, ' * mult(k1);']);
                end
                
            else
                for k1 = 1:length(groups{j})
                    eval(['sums = sums + S.', Vars{groups{j}(k1)}, ';']);
                end
            end
            
            % Set the endpoints of the lines to the sum of the array endpoints            
            SS(i, j + 1, k) = sums;
        end
    end
    
    uns(1, :, k) = unit;
    
%     Legend((k - 1) * m + 1:k * m) = strcat(Model_names(models(k)), ", [", Groups, "]");
      Legend((k - 1) * m + 1:k * m) = strcat("[", Groups, "]");
end

if Style == 0
    [~, b] = ismember(uns, sizes);

    v = max(max(SS(:, 2:end, :).* 10 .^ (3 * (b - 9))));
    
    m = min(v(:));

    Log = floor(log10(m)/3);
    
    units = sizes(9 + Log);
    
    SS(:, 2:end, :) = equiv(SS(:, 2:end, :), uns, units);
end

for i = 1:length(models)
%      plot(log10(SS(:, 1, i)), SS(:, 2:end, i));
        semilogx(SS(:, 1, i), SS(:, 2:end, i), 'LineWidth',5);
        set(gcf,'Position',[500 200 1000 700]);
        set(gca,  'FontSize', 30);
        hold on;
end

legend(Legend);

if ~exist('var_unit', 'var')
    var_unit = unit;
end

if Type == "IV"
%     xlabel(strcat("Initial value of ", Plot_Vars(var), ", ", var_unit, "M"));
%         xlabel(strcat("log[" , Plot_Vars(var), "]"), 'FontSize',30);
        xlabel(strcat("log[", Plot_Vars(var), "] (M)"), 'FontSize',30);
    
elseif Type == "KD"
    K_uns = K_units(var, 2) - K_units(var, 1);
%     xlabel(strcat("k_d value, ", var_unit, "M^{", num2str(K_uns), "}"), 'FontSize',20);
    
     if size(K, 1) == 1 && varz > 1
        xlabel(strcat("k_{d} ", unit, "M"), 'FontSize',30);
    elseif size(K, 1) == 1 && varz < 1
        xlabel(strcat("k_{d} (", unit, "M) while varying backward rate constant"), 'FontSize',30);
    elseif size(K, 1) > 1 && varz > 1
        xlabel(strcat("k_{d}_(_{", num2str(varz), "}_) (", unit, "M)"), 'FontSize',30);
    elseif size(K, 1) > 1 && varz < 1
        xlabel(strcat("k_{d}_(_{", num2str(varz), "}_) (", unit, "M) while varying backward rate constant"), 'FontSize',30);
    else
        xlabel(strcat("k_{d}_(_{", num2str(varz), "}_) (", unit, "M)"), 'FontSize',30);
    end
    
else
    if K_units(Var, 0.5 * (2 - b1)) == 0
        xlabel(strcat("k_{", num2str(b1 * Var), "} value, ", T_unit, "s^{-1}"), 'FontSize',30);
    
    else
        xlabel(strcat("k_{", num2str(b1 * Var), "} value, ", var_unit, "M^{", num2str(K_units(Var, 0.5 * (2 - b1))), "}", T_unit, "s^{-1}"), 'FontSize',30);
    end
end       

% ylabel(strcat("Concentration, ", var_unit, "M"));

 ylabel(strcat("Fraction of species"));
% ylabel(strcat("Fraction of [", Groups, "]"), 'FontSize',30);

hold off;
end


